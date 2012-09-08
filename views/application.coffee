###
methods related to the polling UI
###
@refreshUIFromServer = ->
  $.get('/data', (response) -> 
    refreshCountUI 'cat', response.cat_count
    refreshCountUI 'dog', response.dog_count
    refreshTweetUI('cat', response.cat_tweets)
    refreshTweetUI('dog', response.dog_tweets)
  , "json")

refreshCountUI = (animal, count) ->
  count_selector = $("\##{animal}_count #count")
  diff_selector  = $("\##{animal}_count #diff")
  
  prev_count = parseInt count_selector.text()
  diff = count - prev_count

  count_selector.text count
  count_selector.effect( "highlight", {}, 2000)

  if !isNaN(diff) && diff != 0
    diff_selector.text( "+" + diff )
    diff_selector.show()
    diff_selector.fadeOut(2000)

refreshTweetUI = (animal, tweets) ->
  selector = $("\##{animal}_tweets #tweets")
  selector.hide()
  selector.empty()
  for tweet in tweets
    do (tweet) ->
      selector.append formattedTweet(tweet)
  selector.fadeIn('fast')

###
methods related to the streaming UI
###
@startStreaming = ->
  @source = new EventSource('/subscribe')
  @source.addEventListener('stream.tweets.cat', processCatEvent, false)
  @source.addEventListener('stream.tweets.dog', processDogEvent, false)

@stopStreaming = ->
  @source.close()

processCatEvent = (event) -> updateUIfromStream 'cat', event.data
processDogEvent = (event) -> updateUIfromStream 'dog', event.data

updateUIfromStream = (animal, data) ->
  appendTweetList(animal, $.parseJSON(data) )
  incrementCountUI(animal)

appendTweetList = (animal, tweet) ->
  type = '#' + animal + '_tweets'
  selector = "#{type} ul#tweets"
  list_elements = $("#{selector} li")
  list_elements.first().remove() if list_elements.size() > 10
  $(selector).append( formattedTweet(tweet) )

incrementCountUI = (animal) ->
  count_selector = $("\##{animal}_count #count")
  count = parseInt count_selector.text()
  count_selector.text ++count

###
general purpose UI helpers
###
formattedTweet = (tweet) ->
  tweet_url = "http://twitter.com/#{tweet.username}/status/#{tweet.id}"
  "<li><strong>@#{tweet.username}:</strong> #{tweet.text} <a href='#{tweet_url}'>\#</a></li>"

@startRefreshTimer = ->
  # refreshUIFromServer()
  @refreshTimer = setInterval refreshUIFromServer, 3000

@stopRefreshTimer = ->
  clearInterval(@refreshTimer)

@streamingToggled = ->
  now_enabled = $('#stream_enabled_checkbox').is(':checked')

  if now_enabled
    console.log 'ENABLING STREAMING MODE'
    stopRefreshTimer()
    refreshUIFromServer()
    startStreaming()
    # $('body').animate( {backgroundColor: '#eee'}, "fast")
  else
    console.log 'DISABLING STREAMING MODE'
    stopStreaming()
    refreshUIFromServer()
    startRefreshTimer()
    # $('body').animate( {backgroundColor: '#fff'}, "fast")

$ ->
  setTimeout(refreshUIFromServer, 1)
  startRefreshTimer()

  $('#stream_enabled_checkbox').change ->
    streamingToggled()

