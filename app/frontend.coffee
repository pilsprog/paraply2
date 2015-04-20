###
Handle returning HTML

@author Torstein Thune
###
querystring = require 'querystring'
path = require 'path'
fs = require 'fs'
url = require 'url'
jade = require 'jade'

respond404 = (req, res) ->
	fs.readFile(path.join(process.cwd(), '/public/404.html'), (err, file) ->
		res.writeHead(404)
		res.write(file, 'binary')
		res.end()
	)

respond500 = (req, res, err) ->
	res.writeHead(500, {"Content-Type": "text/plain"})
	res.write('HTTP 500, Paraplyen lekker.')
	res.end()

exports.handle = (request, response) ->
	uri = url.parse(request.url).pathname
	filename = path.join(process.cwd(), '/public/' + uri)
	console.log "filename: #{filename}"
	fs.exists(filename, (exists) ->

		# We have a file that doesn't exist, respond with 404
		if !exists
			respond404(request, response)

			return

		# We have a directory, see if we have a static index file
		if fs.statSync(filename).isDirectory()
			if fs.existsSync(path.join(filename, 'index.jade'))
				filename = path.join(filename, 'index.jade')
			else
				respond404()
				return

		if filename.indexOf('.jade') isnt -1
			try 
				html = jade.renderFile filename, 
					pretty: true
					compileDebug: true
					getHourMinutes: (timestamp) ->
						date = new Date(timestamp)
						return "#{('0'+date.getHours()).slice(-2)}:#{('0' + date.getMinutes()).slice(-2)}"
					events: [
						{
							dateHeader: 'Søndag, 19.03.2015'
							events: [
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
							]
						}
						{
							dateHeader: 'Søndag, 19.03.2015'
							events: [
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
								{
									title: 'Hello world'
									source: 'http://test.test'
									date: new Date().getTime()
									organiser: 'Some group'
									location:
										name: 'Det Akademiske Kvarter'
										address: 'Strømgaten 6, Bergen, Norge'

								}
							]
						}
					]

				response.writeHead(200)
				response.write(html, "binary")
				response.end()

				
			catch e 
				# console.log e
				respond500(request, response, e)

		else
			fs.readFile(filename, "binary", (err, file) ->
				#Something went wrong when reading file
				if err
					respond500(request, response)
					return
				
				# Everything went well, return
				response.writeHead(200)
				response.write(file, "binary")
				response.end()
			)
	)