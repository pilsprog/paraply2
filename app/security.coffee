###
security is a module that handles rate limiting and event validation.
It uses the db module to store information about user submissions.

@author Snorre Magnus Davøen
@copyright Kompiler 2015
###

db = require './db'

_addSubmission = (query) ->
	addSubmissionQuery =
		submission: query.submission
		onSuccess: query.onSuccess
		onError: query.onError
	db.setSubmission addSubmissionQuery

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
