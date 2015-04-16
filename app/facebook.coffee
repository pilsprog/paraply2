###
facebook is a module that handles getting events from Facebook.com.
At the moment only single events that are public can be fetched due to limitations in the API.

@example usage
	facebook = require 'facebook'
	if facebook.canHandle 'https://www.facebook.com/events/344493149083407/'
		facebook.handle 
			url: 'https://www.facebook.com/events/344493149083407/'
			onSuccess: (eventObj) ->
				console.log eventObj
			onError: (errorObj) ->
				console.log errorObj

@example return
	{
		"title": "Event title",
		"source": "http://url.com",
		"date": [timestamp],
		"location": {
			"address": "Addressen til greien",
			"name": "hvis det er et navn på stedet (f.eks Kvarteret/Landmark)",
			"lon": 10
			"lat": 10
		}
	}

@author Torstein Thune
@copyright Kompiler 2015
###

config = (require '../config.coffee').facebook
unless config?.appId and config?.secretKey
	throw new Error('facebook module config missing')

fb = require 'fb'

fb.options
	appId: config.appId
	secretKey: config.secretKey

fb.setAccessToken("#{config.appId}|#{config.secretKey}")

# Get event id
# @param [string] url
# @return [string] id
# @private
_getEventId = (url) ->
	id = (new RegExp(/events\/([0-9a-zA-Z]+)/g)).exec(url)?[1] or= undefined
	return id

# Check if this is a Facebook event url
# @param [string] url
# @return [boolean] canHandle
exports.canHandle = (url) ->
	if url.match(/facebook.com\//) and _getEventId(url)
		return true
	return false

# Get a facebook event
# @param [int] eventId
# @option query [int] eventId
# @option query [function] onSuccess
# @option query [function] onError
# @private
_getEvent = (query) ->
	unless query.eventId 
		query.onError
			error: new Error("No eventId supplied (facebook._getEvent)")
			module: 'facebook'
	else
		fb.api query.eventId, {}, (res) ->
			if not res or res.error 
				query.onError
					error: res.error
					module: 'facebook'
			else
				query.onSuccess
					title: res.name
					description: res.description
					source: ''
					date: new Date(res.start_time).getTime()
					location: ''

# Import and url
# @param [object] query
# @option query [string] url
# @option query [function] onSuccess
# @option query [function] onError
exports.handle = (query) ->
	eventId = _getEventId(query.url)
	if @canHandle(query.url) and eventId 
		query.eventId = eventId
		_getEvent(query)

	else
		query.onError
			error: new Error("Could not get handle query url (#{query.url})")
			module: 'facebook'

# if exports.canHandle 'https://www.facebook.com/events/344493149083407/'
# 	exports.handle 
# 		url: 'https://www.facebook.com/events/344493149083407/'
# 		onSuccess: (eventObj) ->
# 			console.log eventObj
# 		onError: (errorObj) ->
# 			console.log errorObj

