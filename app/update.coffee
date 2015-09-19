###
update is a module for updating events and groups on a scheduled interval.

@author Snorre Magnus Davøen
###
async = require 'async'
cron = require 'cron'
db = require './db'

modules = {}
modules.meetup = require './meetup'
modules.eventbrite = require './eventbrite'
modules.facebook = require './facebook'

updateGroups = () ->
	db.getGroups
		onSuccess: (groups) ->
			async.eachSeries(
				groups,
				(group, callback) ->
					for module, val of modules
						queryObj =
							url: group.source
							onSuccess: -> setTimeout (-> callback null), 1000
							onError: (error) -> console.error error

						break if val.handle?(queryObj)
					console.log "Group handled"
			)
		onError: (error) ->
			console.error error

updateEvents = () ->
	db.getEvents
		onSuccess: (events) ->
			async.eachSeries(
				events,
				(event, callback) ->
					for module, val of modules
						queryObj =
							url: event.source
							onSuccess: -> setTimeout (-> callback null), 1000
							onError: (error) -> callback error

						break if val.handle?(queryObj)
					console.log "Event handled"
				(err) ->
					console.error err
			)
		onError: (error) ->
			console.error error

job = new cron.CronJob(
	'00 00 06 * * *', # Update at six o'clock every day, every week, every month
	(->
		updateEvents()
		updateGroups()),
	(->
		now = new Date()
		console.log "Updated groups and events at #{now}"),
	true,
	'Europe/Paris')
job.start()
