###
meetup is a module that handles fetching events and groups from Meetup.com.
It handles single event URLs as well as group URLs. It only fetches open events.
The Meetup.com API has some rate limiting, which might prevent the module from
fetching.

@example usage
	meetup = require 'meetup'
	
	testEventHandle = () ->
		meetup.handle
			url: "http://www.meetup.com/NNUG-Bergen/events/221170619/"
			onSuccess: (result) ->
				console.log "RESULT", result
			onError: (error) ->
				console.log error.error
	
	testEventHandle()

@author Snorre Magnus Davøen
@copyright Kompiler 2015
###

muAPIKey = (require '../config').meetup

unless muAPIKey
	throw new Error 'MU_API_KEY environment variable missing'

mu = (require 'meetup-api') key: muAPIKey
db = require './db'

muRegex = /// meetup\.com\/      # Match meetup.com/
				[A-Za-z0-9\-]*\/   # Match Letter-109-MeetupGroup/
				events\/          # Match events/
				(\d{9,})\/? ///   # Match 123456789 (least 9 digits, optional /)

muGroupRegex = /// meetup\.com\/
					([A-Za-z0-9\-]*)\/? ///


# Get events by its meetup id
# @param [object] eventQuery
# @param [string] id
# @param [function] onError
# @param [function] onSuccess
# @private
_getEvents = (eventQuery) ->
	if eventQuery.ids?
		muQuery = event_id: eventQuery.ids
	if eventQuery.name?
		muQuery = group_urlname: eventQuery.name

	mu.getEvents(
		muQuery
		(error, events) ->
			if error
				eventQuery.onError error
			else
				console.log 'WE HAVE FEEDBACK\n', events
				eventQuery.onSuccess events.results)


# Get Meetup group by group 'urlname'
# @param [object] eventQuery
# @param [string] name
# @param [function] onError
# @param [function] onSuccess
_getGroups = (groupQuery) ->
	mu.getGroups
		group_urlname: groupQuery.names
		(error, groups) ->
			if error
				groupQuery.onError error
			else
				console.log '\n\n\nWE HAVE A GROUP\n', groups, '\n\n\n'
				groupQuery.onSuccess groups.results[0]


# Parse a Meetup event JSON object
# @param [object] event
_parseEvent = (event) ->
	id: "meetup-event-#{event.id}"
	title: event.name
	source: event.event_url
	date: new Date(event.time)
	raw: event
	location:
		address: event?.venue?.address
		name: event?.venue?.name
		lon: event?.venue?.lon
		lat: event?.venue?.lat


# Parse a Meetup group JSON object
# @param [object] group
_parseGroup = (group) ->
	id: "meetup-group-#{group.id}"
	source: group.link
	raw: group


# Handle a Meetup event add query
# @param [object] query
# @option query [object] event
# @option query [function] onSuccess
# @option query [function] onError
# @private
_handleEvent = (query) ->
	id = (muRegex.exec query.url)[1]
	_getEvents
		ids: [id]
		onError: (error) ->
			query.onError
				error: error
				module: 'meetup'
		onSuccess: (muEvents) ->
			event = _parseEvent muEvents[0]
			db.set
				events: [event]
				onSuccess: query.onSuccess
				onError: query.onError


# Handle Meetup group events
# @param [object] query
# @option query [object] event
# @option query [function] onSuccess
# @option query [function] onError
# @private
_handleGroupEvents = (query) ->
	_getEvents
		name: query.name
		onError: (error) ->
			query.onError
				error: error
				module: 'meetup'
		onSuccess: (muEvents) ->
			events = []
			for event in muEvents
				events.push _parseEvent event
			db.set
				events: events
				onSuccess: query.onSuccess
				onError: query.onError


# Handle a Meetup group add query
# @param [object] query
# @option query [object] event
# @option query [function] onSuccess
# @option query [function] onError
_handleGroup = (query) ->
	name = (muGroupRegex.exec query.url)[1]
	_getGroups
		names: [name]
		onError: (error) ->
			query.onError
				error: error
				module: 'meetup'
		onSuccess: (muGroup) ->
			group = _parseGroup muGroup
			query.name = group.raw.urlname
			db.setGroup
				group: group
				onSuccess: () -> _handleGroupEvents query
				onError: query.onError


# Import and url
# @param [object] query
# @option query [string] url
# @option query [function] onSuccess
# @option query [function] onError
exports.handle = (query) ->
	unless query.url.match(muRegex)? or query.url.match(muGroupRegex)?
		return false
	else
		isEvent = query.url.match(muRegex)?
		if isEvent
			_handleEvent query
		else
			_handleGroup query
		return true