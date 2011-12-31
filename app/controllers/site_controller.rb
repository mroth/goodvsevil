class SiteController < ApplicationController
  def index
    count = REDIS.mget 'cat_count', 'dog_count'
    @cat_count = count[0]
    @dog_count = count[1]
    
    respond_to do |format|
      format.html #index.html.erb
      format.json { 
        render :json  => { 
          :cat_count  => @cat_count, 
          :dog_count  => @dog_count 
        } 
      }
    end
  end

end
