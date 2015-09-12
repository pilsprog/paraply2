###
eventbrite is a module that handles getting events from eventbrite.com.
It supports importation of single events and eventbrite organizations.

@author Torstein Thune
@author Snorre Magnus Davøen
@copyright Kompiler 2015
###

config = (require '../config/config').eventbrite
eventbrite = (require 'eventbrite')({app_key:config.appKey})
db = require './db'

# params = {'city': "Bergen"}

# eventbrite.event_search(params, (err, data)->
#		 console.log(err)
#		 console.log(JSON.stringify(data, false, '\t'))
# )

# Get ID for an eventbrite event
# @param [string] url
# @return id or undefined
_getEventId = (url) ->
	id = (new RegExp(/eventbrite\.com\/e\/[A-Za-z0-9-]*-(\d+)+/g)).exec(url)?[1]
	id ?= undefined
	return id

# Get ID for an eventbrite organiser
# @param [string] url
# @return id or undefined
_getOrganiserId = (url) ->
	id = (new RegExp(/eventbrite\.com\/o\/[A-Za-z0-9-]*-(\d+)+/g)).exec(url)?[1]
	id ?= undefined
	return id

# Get events for an organiser
# @param [object] query This is passed from handle.
# @option query [int] organiserId
# @option query [function] onSuccess
# @option query [function] onError
# @private
_getOrganiserEvents = (query) ->
	unless query.organiserId
		query.onError
			error: new Error("No organiserId supplied (eventbrite._getOrganiserEvents)")
			module: 'eventbrite'
	else
		group = {
			id: "eventbrite-organiser-#{query.organiserId}"
			source: query.url
		}
		db.setGroup
			group: group
			onSuccess: -> # no fucks given
			onError: query.onError

		eventbrite.organizer_list_events({id: query.organiserId}, (err, res) ->
			now = new Date()
			events = []
			for event in res.events
				event = event.event
				date = new Date(event.start_date)
				if date > now
					events.push
						id: "eventbrite-id-#{_getEventId(event.url)}"
						date: date
						source: event.url
						title: event.title
						location:
							address: "#{event.venue.address}, #{event.venue.city}, #{event.venue.country}"
							name: event.venue.name
							lon: event.venue.longitude
							lat: event.venue.latitude

			console.log events
			db.setEvents
				events: events
				onSuccess: query.onSuccess
				onError: query.onError
		)

# Get events for an organiser
# @param [object] query This is passed from handle.
# @option query [int] eventId
# @option query [function] onSuccess
# @option query [function] onError
# @private
_getEvent = (query) ->
	eventbrite.event_get({id: query.eventId}, (err, data) ->
		db.setEvents
			events: [
				id: "eventbrite-event-#{query.eventId}"
				source: data.event.url
				title: data.event.title
				date: new Date(data.event.start_date).getTime()
				location:
					address: "#{data.event.venue.address}, #{data.event.venue.city}, #{data.event.venue.country}"
					name: data.event.venue.name
					lon: data.event.venue.longitude
					lat: data.event.venue.latitude
			]
			onSuccess: query.onSuccess
			onError: query.onError
	)

exports.handle = (query) ->
	eventId = _getEventId(query.url)
	organiserId = _getOrganiserId(query.url)

	if eventId
		query.eventId = eventId
		_getEvent query
		#return true

	else if organiserId
		query.organiserId = organiserId
		_getOrganiserEvents query
		#return true

	return false
