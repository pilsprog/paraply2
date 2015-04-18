###
Elasticsearch package and client object

@author Snorre Davøen
###
elasticsearch = require 'elasticsearch'
client = new elasticsearch.Client
	host: 'localhost:9200'
	log: 'trace'
	apiVersion: '1.5'

createIndex = (name) ->
	client.indices.exists
		'index': name
	.then(
		(exists) ->
			if not exists
				client.indices.create
					'index': name
				.then(
					(body) ->
						console.log "Created #{name} index successfully"
					(error) ->
						console.error 'Failed to create event index')
			else
				console.log "Index already exists"
	
		(error) ->
			console.error error)
  

# Make sure elastic search is running
client.ping
	requestTimeout: Infinity,
	hello: 'elasticsearch!'
.then(
	(body) ->
		createIndex 'events'
		createIndex 'groups'
	(error) ->
		console.error 'Elasticsearch cluster is down'
		throw new Error 'Elastic search cluster is down')


# Normalize url by removing http, www, and trailing slash
normalizeUrl = (url) ->
	return url
  

# Add events to ElasticSearch event index
# @param [object] query
# @option query [array] events
# @option query [function] onSuccess
# @option query [function] onError
set = (query) ->
	console.log JSON.stringify query
	bulkEvents = []
	for event in query.events
		bulkEvents.push
			'index':
				'_index': 'events'
				'_type': 'event'
		event.id = event.source
		bulkEvents.push event

	client.bulk
		'body': bulkEvents
	.then(
		(result) ->
			query.onSuccess "GREAT SUCCESS! ", result
		(error) ->
			query.onError error)


setGroup = (query) ->
	client.create
		'index': 'groups',
		'type': 'group'
		'body': query.group
	.then(
		(result) ->
			query.onSuccess result
		(error) ->
			query.onError error)


exports = module.exports =
	'set': set
	'setGroup': setGroup
