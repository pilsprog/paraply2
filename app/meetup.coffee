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
              [A-Za-z09\-]*\/   # Match Letter-109-MeetupGroup
              events\/          # Match events/
              (\d{9,})\/? ///   # Match 123456789 (least 9 digits)


getEvents = (query) ->
  mu.getEvents
    event_id: query.ids
    (error, events) ->
      if error
        query.onError
          error: error
          module: 'meetup'
      else
        query.onSuccess events


#getEvents
#  ids: [221806583]
#  onSuccess: (event) -> console.log event
#  onError: (error) -> console.log error

# Check if this is a Meetup url
# @param [string] url
exports.canHandle = (url) ->
  if url.match muRegex is not null then true else false


# Import and url
# @param [object] query
# @option query [string] url
# @option query [function] onSuccess
# @option query [function] onError
exports.handle = (query) ->
  id = (muRegex.exec query.url)[1]
  console.log id