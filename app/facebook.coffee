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
fb = require 'fb'

# Check if this is a Facebook url
# @param [string] url
exports.canHandle = (url) ->
	return false
# Import and url
# @param [object] query
# @option query [string] url
# @option query [function] onSuccess
# @option query [function] onError
exports.handle = (query) ->