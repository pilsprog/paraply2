###
Handle returning HTML

@author Torstein Thune
###
querystring = require 'querystring'
path = require 'path'
fs = require 'fs'
url = require 'url'

exports.handle = (request, response) ->
	uri = url.parse(request.url).pathname
	filename = path.join(process.cwd(), '/frontend/' + uri)
	console.log "filename: #{filename}"
	fs.exists(filename, (exists) ->

		# We have a file that doesn't exist, respond with 404
		if !exists
			fs.readFile(path.join(process.cwd(), '/frontend/404.html'), (err, file) ->
				response.writeHead(404)
				response.write(file, 'binary')
				response.end()	
			)
			return

		# We have a directory, see if we have a static index file
		if fs.statSync(filename).isDirectory()
			if fs.existsSync(path.join(filename, 'index.html'))
				filename = path.join(filename, 'index.html')
			else
				filename = path.join(process.cwd(), '/frontend/404.html')

		fs.readFile(filename, "binary", (err, file) ->
			#Something went wrong when reading file
			if err
				response.writeHead(500, {"Content-Type": "text/plain"})
				response.write(err + "\n")
				response.end()
				return
			

			# Everything went well, return
			response.writeHead(200)
			response.write(file, "binary")
			response.end()
		)
	)