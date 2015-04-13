###
Elasticsearch package and client object

@author Snorre Davøen
###
elasticsearch = require 'elasticsearch'
client = new elasticsearch.Client
  host: 'localhost:9200',
  log: 'trace',
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
            console.trace 'Failed to create event index')
    
    (error) ->
      console.trace error)
  

# Make sure elastic search is running
client.ping
  requestTimeout: Infinity,
  hello: 'elasticsearch!'
.then(
  (body) ->
    createIndex('events')
    createIndex('groups')
  (error) ->
    console.trace 'Elasticsearch cluster is down'
    process.exit(1))


set = (query) ->
  client.create
    'index': 'events'
    'type': 'event'
    'body': query.event
  .then(
    (result) ->
      query.onSuccess result
    (error) ->
      query.onError error)


setGroup = (query) ->
  client.create
    'index': 'groups'
    'body': query.group
  .then(
    (result) ->
      query.onSuccess result
    (error) ->
      query.onError error)


exports = module.exports =
  'set': set
  'setGroup': setGroup
