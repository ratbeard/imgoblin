express = require 'express'
cors = require 'cors'
fs = require 'fs'
path = require 'path'

PORT = 7777

# 
# Middleware
#
app = express()
app.use(express.logger('dev'))
app.use(cors())
app.use(express.bodyParser({}))
app.use(express.static(path.join(__dirname, 'public')))


uniqueId = () ->
	"id" + (Math.random() * 123427 | 0)

class UploadedImage
	constructor: (attributes={}) ->
		@[k] = v for k, v of attributes

	@create: (attributes={}) ->
		attributes.id = uniqueId()
		new @(attributes)

class UploadedImagePersistance
	@findOrCreateByCid: (cid, callback) ->
		@findByCid cid, (err, image) ->
			console.log 'creating imageupload' unless image
			image ?= UploadedImage.create(cid: cid)
			callback(err, image)

	@findByCid: (cid, callback) ->
		@loadImages (err, images) ->
			console.log 'IMAGES: ', images
			for image in images
				if image.cid == cid
					callback(err, new UploadedImage(image))
					return
			console.log 'no dice :('
			callback(err, null)

	@loadImages: (callback) ->
		fs.readFile './db.json', 'utf8', (err, text) ->
			if err?.code == 'ENOENT'
				return callback(null, [])
			throw err if err
			data = JSON.parse(text)
			callback(err, data)

	@save: (uploadedImage) ->
		@loadImages (err, images) ->
			found = false
			for image, i in images
				if image.id == uploadedImage.id
					images[i] = uploadedImage
					found = true
			if !found
				images.push(uploadedImage)
			
			fs.writeFile("./db.json", JSON.stringify(images, '', '\t'))




#
# Routes
#
app.get '/', (request, response) ->
	rootUrl = "http://#{request.headers.host}"
	response.send rootUrl

app.put '/upload/:cid', (request, response) ->
	{cid} = request.params
	{name} = request.body

	UploadedImagePersistance.findOrCreateByCid cid, (err, uploadedImage) ->
		if name
			console.log "UPDATING NAME", name
			uploadedImage.name = name
			UploadedImagePersistance.save(uploadedImage)

		# TODO handle multiple files
		uploadedFile = request.files?.image
		if uploadedFile
			console.log 'got file!'
			console.log uploadedFile
			fileExtension = {
				'image/png': '.png'
				'image/jpeg': '.jpeg'
				'image/gif': '.gif'
			}[uploadedFile.headers['content-type']]

			# TODO check not overwriting a file
			# TODO check is actually an image file
			isValidImageFile = fileExtension?
			isNewRecord = !uploadedImage.url?
			if isValidImageFile && isNewRecord
				oldPath = uploadedFile.path
				fileName = uploadedImage.id + fileExtension
				newPath = path.join(__dirname, "public", fileName)
				console.log 'renaming file %s -> %s', oldPath, newPath
				fs.rename(oldPath, newPath)
				url = "http://#{request.headers.host}/#{fileName}"
				uploadedImage.url = url
				UploadedImagePersistance.save(uploadedImage)
				

		response.send JSON.stringify(uploadedImage)
	

app.get '/images.json', (request, response) ->
	UploadedImagePersistance.loadImages (err, images) ->
		response.send(JSON.stringify(images))

#
# Run
#
app.listen(PORT)
module.exports = app
