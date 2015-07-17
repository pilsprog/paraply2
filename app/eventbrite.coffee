config = (require '../config').eventbrite
eventbrite = (require 'eventbrite')({app_key:config.appKey})

# params = {'city': "Bergen"}

# eventbrite.event_search(params, (err, data)->
#     console.log(err)
#     console.log(JSON.stringify(data, false, '\t'))
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
	unless query.eventId 
		query.onError
			error: new Error("No eventId supplied (eventbrite._getOrganiserEvents)")
			module: 'eventbrite'
	else
		db.setGroup
			id: "eventbrite-organiser-#{query.organiserId}"
			source: query.url
			onSuccess: -> # no fucks given
			onError: query.onError

		eventbrite.organizer_list_events({id: query.organiserId}, (err, res) ->

			now = new Date().getTime()
			events = []

			for event in res.events
				date = new Date(event.start_date)
				if date < now
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

			db.set 
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
	console.log 'eventbrite._getEvent'
	eventbrite.event_get({id: query.eventId}, (err, data) ->
		db.set 
			events: [
				id: "eventbrite-event-#{eventId}"
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
	console.log 'eventbrite.handle'
	eventId = _getEventId(query.url)
	console.log eventId
	organiserId = _getOrganiserId(query.url)

	if eventId
		console.log "eventId: #{eventId}"
		query.eventId = eventId
		_getEvent query
		#return true
	
	else if organiserId
		console.log "organiserId: #{eventId}"
		query.organiserId = organiserId
		_getOrganiserId query
		#return true

	return false 



# console.log _getEventId('http://www.eventbrite.com/e/23-april-2015-kl-1800-first-tuesday-partner-middag-scandic-rnen-hotell-tickets-16629131179?lololol124234')
# console.log _getOrganiserId 'http://www.eventbrite.com/o/first-tuesday-bergen-311277798?s='

# eventbrite.organizer_list_events({id: 311277798}, (err, res) ->
# 	console.log res
# )
