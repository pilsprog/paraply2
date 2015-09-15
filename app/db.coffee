###
db is a database module that handles storage and retrieval of events and groups.
It uses ElasticSearch as a database backend and the elasticsearch JavaScript
client.

@author Snorre Davøen
###
elasticsearch = require 'elasticsearch'
client = new elasticsearch.Client (require '../config/config').elasticsearch


# Add ID mapping to index
# @param [string] name of index
# @private
_putIdMapping = (name) ->
	client.indices.putMapping


# Create Elastic Search index with given name.
# @param [string] name of the index
# @private
_createIndex = (name) ->
	params =
		'index': name
		'mappings': {}


	if name is 'events'
		params.mappings.event = '_id': 'path': 'id'
	else
		params.mappings.group = '_id': 'path': 'id'

	client.indices.exists
		'index': name
	.then(
		(exists) ->
			if not exists
				client.indices.create
					'index': name
					'_id':
						'path': 'id'
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
		_createIndex 'events'
		_createIndex 'groups'
		_createIndex 'submissions'
	(error) ->
		console.error 'Elasticsearch cluster is down'
		throw new Error 'Elastic search cluster is down')


# Add events to ElasticSearch event index
# @param [object] query
# @option query [array] events
# @option query [function] onSuccess
# @option query [function] onError
setEvents = (query) ->
	bulkEvents = []
	for event in query.events
		bulkEvents.push
			'index':
				'_index': 'events'
				'_type': 'event'
				'_id': event.id
		bulkEvents.push event

	client.bulk
		'body': bulkEvents
	.then(
		(result) ->
			query.onSuccess result
		(error) ->
			query.onError
				error: error
				module: 'db')


# Add events to ElasticSearch event index
# @param [object] query
# @option query [object] group
# @option query [function] onSuccess
# @option query [function] onError
setGroup = (query) ->
	client.index
		'index': 'groups',
		'type': 'group'
		'id': query.group.id
		'body': query.group
	.then(
		(result) ->
			query.onSuccess result
		(error) ->
			query.onError
				error: error
				module: 'db')


# Add user submission info to ElasticSearch submissions index
# @param [object] query
# @option query [object] submission
# @option query [function] onSuccess
# @option query [function] onError
setSubmission = (query) ->
	client.index
		'index': 'submissions',
		'type': 'submission'
		'body': query.submission
	.then(
		(result) ->
			query.onSuccess result
		(error) ->
			query.onError
				error: error
				module: 'db')


# Get all upcoming events including recently started ones.
# Returns events based on server time minus three hours for ongoing events.
# @param [object] query
# @option query [function] onSuccess
# @option query [function] onError
getEvents = (query) ->
	client.search
		index: 'events'
		body:
			query: filtered: filter: range: date: gt: 'now-3h'
			sort: date: order: "asc"
	.then(
		(esEvents) ->
			events = []
			for event in esEvents.hits.hits
				events.push event._source
			query.onSuccess events
		(error) ->
			query.onError
				error: error
				module: 'db')


# Get all groups from group index
# @param [object] query
# @option query [function] onSuccess
# @option query [function] onError
getGroups = (query) ->
	client.search
		index: 'groups'
		body: query: match_all: {}
	.then(
		(esGroups) ->
			groups = []
			for group in esGroups.hits.hits
				groups.push group._source
			query.onSuccess groups
		(error) ->
			query.onError
				error: error
				module: 'db')

# Get the submission count of a user
# @oaram [object] query
# @option query [string] ipAddress
# @option query [Date] dateFrom
# @option query [function] onSuccess
# @option query [function] onError
getSubmissionCount = (query) ->
	client.search
		index: 'submissions'
		body:
			query: filtered: filter: range: date: gt: 'now-3m'
			sort: date: order: "asc"
	.then(
		(esSubmissions) ->
			query.onSuccess esSubmissions.hits.hits.length
		(error) ->
			query.onError
				error: error
				module: 'db')

# Export set and setGroup functions
exports = module.exports =
	'setEvents': setEvents
	'setGroup': setGroup
	'setSubmission': setSubmission
	'getEvents': getEvents
	'getGroups': getGroups
	'getSubmissionCount': getSubmissionCount
