###
Handle returning HTML

@author Torstein Thune
###
querystring = require 'querystring'
path = require 'path'
fs = require 'fs'
url = require 'url'

respond404 = (req, res) ->
	fs.readFile(path.join(process.cwd(), '/public/404.html'), (err, file) ->
		res.writeHead(404)
		res.write(file, 'binary')
		res.end()	
	)

respond500 = (req, res) ->
	res.writeHead(500, {"Content-Type": "text/plain"})
	res.write(err + "\n")
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
			if fs.existsSync(path.join(filename, 'index.html'))
				filename = path.join(filename, 'index.html')
			else
				respond404()
				return

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