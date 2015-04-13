###
Glue/server logic.

Lets event API handler modules determine what to do with any POSTed urls.
Lets the datahandler see what to do with any GET requests.

@author Torstein Thune
###

http = require 'http'
querystring = require 'querystring'
colors = require 'colors'
path = require 'path'
fs = require 'fs'
url = require 'url'
port = process.argv[2] || 8888 # port to start paraply on

#db = require './db'

# Handle post requests (e.g urls for adding events)
postHandler = (req, res) ->
	req.body = ''
	req.addListener('data', (chunk) ->
		req.body += chunk
	)

	req.addListener('error', (error) ->
		console.error('got a error', error)
	)

	req.addListener('end', (chunk) ->
		req.body += chunk if chunk

		url = decodeURIComponent(req.body)

		res.writeHead(200)
		res.end('{ "went": "ok" }')
	)

frontendHandler = (request, response) ->
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

# Handle GET requests (e.g getting JSON)
getHandler = (req, res) ->
	frontendHandler(req, res)
	# res.writeHead(200)
	# res.write('Hello world!')
	# res.end()

# Wrapper for handling requests
requestHandler = (req, res) ->
	if req.method is 'GET'
		getHandler(req,res)
	else if req.method is 'POST'
		postHandler(req,res)

# Start the server
http.createServer(requestHandler).listen(parseInt(port, 10))

# Really important =D
console.log "\n\n\n
			yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyyy++yyyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyys  syyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyysssssso+.  .+ossssssyyyyyyyyyy\n
			yyyyyyy:`         `+/`         `:yyyyyyy\n
			yyyyyy+ `/ooooooosyyyysooooooo/` +yyyyyy\n
			yyyyyy: :yyyyyyyyys--oyyyyyyyyy: :yyyyyy\n
			yyyyyyo+syyyyyyyyyo  +yyyyyyyyys+oyyyyyy\n
			yyyyyyyyyyyyyyyyyyo  +yyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyyo  +yyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyys--oyyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyyy/:+yyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyyy` :yyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyyo .syyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyy.-yyyyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyys+yyyyyyyyyyyyyyyyyyyyy\n
			yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy\n"['red']
console.log ' Paraply started @ ' + "http://localhost:#{port}\n\n\n"['cyan']



