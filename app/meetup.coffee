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

muAPIKey = process.env.MU_API_KEY

unless muAPIKey
  console.error 'MU_API_KEY environment variable missing'
  process.exit(1)

mu = (require 'meetup-api') key: muAPIKey

muRegex = /// meetup.com\/      # Match meetup.com/
              [A-Za-z09\-]*\/   # Match Letter-109-MeetupGroup/
              events\/          # Match events/
              (\d{9,})\/? ///   # Match 123456789 (least 9 digits, optional /)


# Get event by its meetup id
# @param [string] id
# @param [function] onError
# @param [function] onSuccess
getEvent = (id, onError, onSuccess) ->
  mu.getEvents
    event_id: id
    (error, events) ->
      if error
        onError
          error: error
          module: 'meetup'
      else
        event = parseEvent events.results[0]
        onSuccess event

# Parse a meetup json event object
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


# Check if this is a Meetup url
# @param [string] url
exports.canHandle = (url) ->
  unless (url.match muRegex) is null then true else false


# Import and url
# @param [object] query
# @option query [string] url
# @option query [function] onSuccess
# @option query [function] onError
exports.handle = (query) ->
  id = (muRegex.exec query.url)[1]
  getEvent id, query.onError, query.onSuccess