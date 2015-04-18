###
Module to fetch meetup events

@author Snorre Magnus Davøen
###

###
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
###

muAPIKey = (require '../config.coffee').meetup

unless muAPIKey
	throw new Error 'MU_API_KEY environment variable missing'

mu = (require 'meetup-api') key: muAPIKey
db = require './db'

muRegex = /// meetup\.com\/      # Match meetup.com/
				[A-Za-z09\-]*\/   # Match Letter-109-MeetupGroup/
				events\/          # Match events/
				(\d{9,})\/? ///   # Match 123456789 (least 9 digits, optional /)

muGroupRegex = /// meetup\.com\/
					([A-Za-z09\-]*)\/? ///


# Get events by its meetup id
# @param [object] eventQuery
# @param [string] id
# @param [function] onError
# @param [function] onSuccess
getEvents = (eventQuery) ->
	mu.getEvents
		event_id: eventQuery.ids
		(error, events) ->
			if error
				eventQuery.onError error
			else
				eventQuery.onSuccess events.results


# Get Meetup group by group 'urlname'
# @param [object] eventQuery
# @param [string] name
# @param [function] onError
# @param [function] onSuccess
getGroup = (groupQuery) ->
	mu.getGroups
		group_urlname: groupQuery.name
		(error, groups) ->
			if error
				groupQuery.onError error
			else
				groupQuery.onSuccess groups.results[0]


# Parse a Meetup event JSON object
# @param [object] event
parseEvent = (event) ->
	title: event.name
	source: event.event_url
	date: new Date(event.time)
	location:
		address: event.venue.address
		name: event.venue.name
		lon: event.venue.lon
		lat: event.venue.lat


# Parse a Meetup group JSON object
# @param [object] group
parseGroup = (group) ->
	source: group.link


# Handle a Meetup event add query
# @param [object] query
# @option query [object] event
# @option query [function] onSuccess
# @option query [function] onError
handleEvent = (query) ->
	id = (muRegex.exec query.url)[1]
	getEvents
		ids: [id]
		onError: (error) ->
			query.onError
				error: error
				module: 'meetup'
		onSuccess: (muEvents) ->
			event = parseEvent muEvents[0]
			db.set
				events: [event]
				onSuccess: query.onSuccess
				onError: query.onError


# Handle a Meetup group add query
# @param [object] query
# @option query [object] event
# @option query [function] onSuccess
# @option query [function] onError
handleGroup = (query) ->
	name = (muGroupRegex.exec query.url)[1]
	getGroup
		name: name
		onError: (error) ->
			query.onError
				error: error
				module: 'meetup'
		onSuccess: (muGroup) ->
			group = parseGroup muGroup
			db.setGroup
				group: group
				onSuccess: query.onSuccess
				onError: query.onError


# Check if this is a Meetup url
# @param [string] url
#exports.canHandle = (url) ->
#  return url.match(muRegex)? or url.match(muGroupRegex)?

# Import and url
# @param [object] query
# @option query [string] url
# @option query [function] onSuccess
# @option query [function] onError
exports.handle = (query) ->
	unless query.url.match(muRegex)? or query.url.match(muGroupRegex)?
		console.log "is false"
		return false
	else
		isEvent = query.url.match(muRegex)?
		if isEvent
			console.log "Is event true"
			handleEvent query
		else
			handleGroup query
		return true