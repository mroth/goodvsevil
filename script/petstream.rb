require 'rubygems'
require 'tweetstream'
require 'oj'
require 'colored'
require 'redis'
require 'uri'
require 'json'

# secret tokens
CONSUMER_KEY = ENV['CONSUMER_KEY']
CONSUMER_SECRET = ENV['CONSUMER_SECRET']
OAUTH_TOKEN = ENV['OAUTH_TOKEN']
OAUTH_TOKEN_SECRET = ENV['OAUTH_TOKEN_SECRET']

# configure tweetstream instance
TweetStream.configure do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = OAUTH_TOKEN
  config.oauth_token_secret = OAUTH_TOKEN_SECRET
  config.auth_method = :oauth
  config.parser   = :yajl
end

# db setup
uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

# my options
VERBOSE = ENV["VERBOSE"] || false

#setup
DOGTERMS = %w[dog dogs doggy doggie doggies puppy puppies]
CATTERMS = %w[cat cats kitty kittie kitties kitten kittens]
TERMS = DOGTERMS + CATTERMS

puts "Setting up a stream to track terms '#{TERMS}'..."
@client = TweetStream::Client.new
@client.on_error do |message|
  # Log your error message somewhere
  puts "ERROR: #{message}"
end
@client.on_limit do |skip_count|
  # do something
  puts "RATE LIMITED LOL"
end
@client.track(TERMS) do |status|
  puts " ** @#{status.user.screen_name}: ".green + status.text.white if VERBOSE
  status_small = {
    :id => status.id.to_s,
    :text => status.text,
    :username => status.user.screen_name
  }
  
  if status.text =~ /#{DOGTERMS.join('|')}/i
    puts "   ...doggie!" if VERBOSE
    REDIS.INCR 'dog_count'
    REDIS.PUBLISH 'stream.tweets.dog', status_small.to_json
    REDIS.LPUSH 'dog_tweets', status_small.to_json
    REDIS.LTRIM 'dog_tweets',0,9
  end
  if status.text =~ /#{CATTERMS.join('|')}/i
    puts "   ...kitty!" if VERBOSE
    REDIS.INCR 'cat_count'
    REDIS.PUBLISH 'stream.tweets.cat', status_small.to_json
    REDIS.LPUSH 'cat_tweets', status_small.to_json
    REDIS.LTRIM 'cat_tweets',0,9
  end
end
