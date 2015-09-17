###
security is a module that handles rate limiting and event validation.
It uses the db module to store information about user submissions.

@author Snorre Magnus Davøen
@copyright Kompiler 2015
###
config = (require '../config/config').security
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

exports.verifySubmission = verifySubmission
