express = require 'express'
cors = require 'cors'
fs = require 'fs'
path = require 'path'

#
# Config
#
PORT = 7777

app = express()
app.use(express.logger('dev'))
app.use(cors())
app.use(express.bodyParser({}))
app.use(express.static(path.join(__dirname, 'public')))


# Model of an uploaded image.
class Image
	@create: (attributes) ->
		new @(attributes)

	constructor: (attributes={}) ->
		@[k] = v for k, v of attributes


# Storage layer for an uploaded image.
# Its a json file thats stored on disk.  Since there won't be many uploads,
# should be fine for now :)
class ImagePersistance
	@findOrCreateById: (id, callback) ->
		@findById id, (err, image) ->
			image ?= Image.create(id: id)
			callback(err, image)

	@findById: (id, callback) ->
		@loadImages (err, images) ->
			callback(err, null) if err
			for image in images
				if image.id == id
					return callback(null, new Image(image))
			callback(null, null)

	@loadImages: (callback) ->
		fs.readFile './db.json', 'utf8', (err, text) ->
			if err
				# OK if file doesn't exist - it'll be created on the first upload
				return callback(null, []) if err.code == 'ENOENT'
				return callback(err, null)
			callback(null, JSON.parse(text))

	# Create or update an image.
	# If updating an existing image, override it with the given image.
	# If creating an image, add it to the array of images.
	# Then save and overwrite the db.json file
	@save: (imageToSave) ->
		@loadImages (err, images) ->
			found = false
			for image, i in images
				if image.id == imageToSave.id
					images[i] = imageToSave
					found = true
					break

			if !found
				images.push(imageToSave)

			fs.writeFile("./db.json", JSON.stringify(images, '', '\t'))

#
# Helpers
#
sendError = (response, message) ->
	response.statusCode = 400
	response.send(JSON.stringify(error: message))


#
# Routes
#

# GET /
# Test route, not used.
app.get '/', (request, response) ->
	rootUrl = "http://#{request.headers.host}"
	response.send(rootUrl)


# PUT /upload/178346
# Handle an image upload or setting the images name.
app.put '/upload/:id', (request, response) ->
	{id} = request.params
	{name} = request.body
	uploadedFile = request.files?.image

	if !name? && !uploadedFile?
		return sendError(response, "Must send a name or image upload")

	if name? && uploadFile?
		return sendError(response, "Cant send name and image upload")

	ImagePersistance.findOrCreateById id, (err, image) ->
		if err
			console.log "ERROR!", err
			return sendError("¯\_(⊙︿⊙)_/¯")

		if !image && name?
			return sendError("Could not find image")

		if image.url? && uploadedFile
			return sendError("Cant modify an image file")
		
		if name
			console.log "UPDATING NAME", name
			image.name = name
			ImagePersistance.save(image)
			return response.send(JSON.stringify(image))

		if uploadedFile
			# TODO handle multiple files
			console.log 'got file!'
			#console.log uploadedFile

			# TODO check is actually an image file
			contentType = uploadedFile.headers['content-type']
			fileExtension = {
				'image/png': '.png'
				'image/jpeg': '.jpeg'
				'image/gif': '.gif'
			}[contentType]
			if !fileExtension?
				return sendError("Invalid image file")
			
			oldPath = uploadedFile.path
			fileName = image.id + fileExtension
			newPath = path.join(__dirname, "public", fileName)
			console.log 'renaming file %s -> %s', oldPath, newPath
			fs.rename(oldPath, newPath)
			url = "http://#{request.headers.host}/#{fileName}"
			image.url = url
			ImagePersistance.save(image)
			return response.send(JSON.stringify(image))
				
	
# GET /images.json
# Returns a list of all the images in the "database" ;) ;)
app.get '/images.json', (request, response) ->
	ImagePersistance.loadImages (err, images) ->
		response.send(JSON.stringify(images))


#
# Run
#
app.listen(PORT)
module.exports = app

