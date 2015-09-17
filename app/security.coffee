###
security is a module that handles rate limiting and event validation.
It uses the db module to store information about user submissions.

@author Snorre Magnus Davøen
@copyright Kompiler 2015
###
config = (require '../config/config').security
geolib = require 'geolib'
http = require 'http'
db = require './db'

# Adds a user submission object to database
# @param [object] query
# @option query [object] submission
# @option query [function] onSuccess
# @option query [function] onError
# @private
_addSubmission = (query) ->
	addSubmissionQuery =
		submission: query.submission
		onSuccess: query.onSuccess
		onError: query.onError
	db.setSubmission addSubmissionQuery

# Verifies a user submission, i.e. checks if rate limiting should be applied
# @param [object] query
# @option query [object] req object from node httpserver module
# @option query [function] onSuccess
# @option query [function] onError
verifySubmission = (query) ->
	verifySubmissionQuery =
		ip: query.req.connection.remoteAddress
		onSuccess: (count) ->
			if count < 10
				query.onSuccess()
			else
				query.onError()
		onError: ->
			query.onError()

	insertSubmissionQuery =
		submission:
			ip: query.req.connection.remoteAddress
			date: new Date()
		onSuccess: ->
			db.getSubmissionCount verifySubmissionQuery
		onError: (error) ->
			query.onError()

	_addSubmission insertSubmissionQuery

# Checks if distance between event and predefined position is greater than some
# max distance (in meters).
# @param [object] query
# @option query [number] lon
# @option query [number] lat
# @option query [function] onSuccess
# @option query [function] onError
# @private
_geoPosDistInsideMax = (geoPostition) ->
	distance = geolib.getDistance {
			latitude: geoPostition.lat
			longitude: geoPostition.lon},
		{
			latitude: config.geo.center.lat
			longitude: config.geo.center.lon},
		100

	return distance < config.geo.maxdist

# Verifies the event location based on lat and lon coordinates
# @param [object] query
# @option query [number] lon
# @option query [number] lat
# @option query [function] onSuccess
# @option query [function] onError
# @private
_verifyGeoPosLonLat = (query) ->
	distance =
	if _geoPosDistInsideMax query
		query.onSuccess()
	else
		query.onError()

# Verifies the event location based on address
# @param [object] query
# @option query [number] lon
# @option query [number] lat
# @option query [function] onSuccess
# @option query [function] onError
# @private
_verifyGeoPosAddress = (query) ->
	url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{query.address}"

	http.get(url, (res) ->
		body = ''
		res.on 'data', (chunk) ->
			body += chunk
		res.on 'end', ->
			jsonResponse = JSON.parse body
			locationMatch = false
			for result in jsonResponse.results
				geopos = result.geometry.location
				geopos.lon = geopos.lng # Google uses non-standard shorthand
				if  _geoPosDistInsideMax geopos
					locationMatch = true

			if locationMatch
				query.onSuccess()
			else
				query.onError()
		res.on 'error', ->
			console.log 'error')

# Verifies that an event takes place within the given geographical area
# @param [object] query
# @option query [number] lon
# @option query [number] lat
# @option query [function] onSuccess
# @option query [function] onError
verifyGeographicPosition = (query) ->
	query = query.event
	if query.lon and query.lat
		_verifyGeoPosLonLat query
	else if query.address
		_verifyGeoPosAddress query
	else
		query.onError()

verifyGeographicPositions = (query) ->
	async.filterseries(
		query.events,
		(event, callback) ->
			verifyEventQuery =
				event: event
				onError: () -> callback false
				onSuccess: () -> setTimeout ( -> callback(true)), 150
			console.log 'Verify event plox'
			verifyGeographicPosition verifyEventQuery
		(verifiedEvents) ->
			query.onSuccess events)

exports.verifySubmission = verifySubmission
