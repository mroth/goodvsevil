# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

updateValues = ->
	$.get('/site/index.json', (response) ->
		$('#cat_count #count').text( response.cat_count )
		$('#cat_count #count').effect( "highlight", {}, 1000 )
		$('#dog_count #count').text( response.dog_count )
		$('#dog_count #count').effect( "highlight", {}, 1000 )
		
	, "json")
	setTimeout(updateValues, 3000)

$ ->
	setTimeout(updateValues, 3000)
