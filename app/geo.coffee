###
geo is a module that handles geo filtering.
It uses the google api to fetch lon and lat values for adresses.

@author Snorre Magnus Davøen
@copyright Kompiler 2015
###

config = (require '../config/config').geo
async = require 'async'
geolib = require 'geolib'
http = require 'http'

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
			latitude: config.center.lat
			longitude: config.center.lon},
		100
	# Transform kilometers into meters
	return distance < config.maxDistKilometers * 1000

# Verifies the event location based on lat and lon coordinates
# @param [object] query
# @option query [number] lon
# @option query [number] lat
# @option query [function] onSuccess
# @option query [function] onError
# @private
_verifyGeoPosLonLat = (query) ->
	distance =
	if _geoPosDistInsideMax query.event.location
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
	address = query.event.location.address
	url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{address}"

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
				setTimeout (-> query.onSuccess()), 150

			else
				query.onError()
		res.on 'error', ->
			query.onError())

# Verifies that an event takes place within the given geographical area
# @param [object] query
# @option query [number] lon
# @option query [number] lat
# @option query [function] onSuccess
# @option query [function] onError
# @private
_verifyGeographicPosition = (query) ->
	if query.event.location.lon and query.event.location.lat
		_verifyGeoPosLonLat query
	else if query.event.address
		_verifyGeoPosAddress query
	else
		query.onError()

verifyGeographicPositions = (query) ->
	async.filterSeries(
		query.events,
		(event, callback) ->
			verifyEventQuery =
				event: event
				onError: () -> callback false
				onSuccess: () -> callback true
			_verifyGeographicPosition verifyEventQuery
		(verifiedEvents) ->
			query.onSuccess verifiedEvents)

exports.verifyGeographicPositions = verifyGeographicPositions
