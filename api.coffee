###
Handle returning JSON

@author Torstein Thune
###
exports.handle = (req, res) ->
	res.writeHeader(200)
	res.write({"hello": "world"})
	res.end()