###
update is a module for updating events and groups on a scheduled interval.

@author Snorre Magnus Davøen
###
db = require './db'

modules = {}
modules.meetup = require './meetup'
modules.eventbrite = require './eventbrite'
modules.facebook = require './facebook'

updateGroups = () ->
	db.getGroups
		onSuccess: (groups) ->
			for group in groups
				for module, val of modules
					queryObj =
						url: group.source
						onSuccess: () -> #Fire and forget
						onError: (error) -> console.error error

					break if val.handle?(queryObj)

		onError: (error) ->
			console.error error

updateGroups()

updateEvents = () ->
	db.get
		onSuccess: (events) ->
			for event in events
				for module, val of modules
					queryObj =
						url: event.source
						onSuccess: () -> #Fire and forget
						onError: (error) -> console.error error

					break if val.handle?(queryObj)

		onError: (error) ->
			console.error error

updateEvents()
