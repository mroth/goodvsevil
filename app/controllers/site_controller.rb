class SiteController < ApplicationController
  def index
    count = REDIS.mget 'cat_count', 'dog_count'
    dog_tweets = REDIS.lrange 'dog_tweets',0,9
    cat_tweets = REDIS.lrange 'cat_tweets',0,9
    dog_tweets.map! {|t| JSON.parse(t)}
    cat_tweets.map! {|t| JSON.parse(t)}
    @cat_count = count[0].to_i
    @dog_count = count[1].to_i
    
    respond_to do |format|
      format.html #index.html.erb
      format.json { 
        render :json  => { 
          :cat_count  => @cat_count, 
          :dog_count  => @dog_count,
          :cat_tweets => cat_tweets,
          :dog_tweets => dog_tweets
        } 
      }
    end
  end

end
