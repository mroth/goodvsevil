# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

updateValues = ->
	$.get('/site/index.json', (response) ->	
		updateCountUI('#cat_count', response.cat_count)
		updateCountUI('#dog_count', response.dog_count)
		updateTweetUI('#cat_tweets', response.cat_tweets)
		updateTweetUI('#dog_tweets', response.dog_tweets)
	, "json")
	setTimeout(updateValues, 8000)

updateTweetUI = (selector, tweets) ->
	selector = selector + ' #tweets'
	$(selector).hide()
	$(selector).empty()
	for tweet in tweets
		do (tweet) ->
			# console.log(tweet.id)
			$(selector).append("<li><strong>@#{tweet.username}:</strong> #{tweet.text}</li>")
	$(selector).fadeIn('fast')

updateCountUI = (selector, count) ->
	count_selector = selector + ' #count'
	diff_selector = selector + ' #diff'
	
	prev_count = parseInt( $(count_selector).text() )
	diff = count - prev_count
	
	$(count_selector).text( count )
	$(count_selector).effect( "highlight", {}, 2000)
	
	$(diff_selector).text( "+" + diff )
	$(diff_selector).show()
	$(diff_selector).fadeOut(2000)

$ ->
	setTimeout(updateValues, 10)
