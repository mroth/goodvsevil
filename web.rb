require 'sinatra'
require 'redis'
require 'slim'
require 'coffee-script'
require 'oj'

configure do
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  # Oj.mimic_JSON
end
configure :production do
  require 'newrelic_rpm'
end
conns = []

get '/' do
  slim :index
end

get '/application.js' do
  coffee :application
end

get '/data' do
  @count = REDIS.mget 'cat_count', 'dog_count'
  @dog_tweets = REDIS.lrange 'dog_tweets',0,9
  @cat_tweets = REDIS.lrange 'cat_tweets',0,9
  @dog_tweets.map! {|t| Oj.load(t)}
  @cat_tweets.map! {|t| Oj.load(t)}
  @cat_count = @count[0].to_i
  @dog_count = @count[1].to_i

  content_type :json
  Oj.dump( {
    'cat_count'  => @cat_count,
    'dog_count'  => @dog_count,
    'cat_tweets' => @cat_tweets,
    'dog_tweets' => @dog_tweets
  } )
end

get '/subscribe' do
  content_type 'text/event-stream'
  stream(:keep_open) do |out|
    conns << out
    out.callback { conns.delete(out) }
  end
end

Thread.new do
  uri = URI.parse(ENV["REDISTOGO_URL"])
  redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

  redis.psubscribe('stream.tweets.*') do |on|
    on.pmessage do |match, channel, message|
      type = channel.sub('stream.tweets.', '')

      conns.each do |out|
        out << "event: #{channel}\n"
        out << "data: #{message}\n\n"
      end
    end
  end

end
