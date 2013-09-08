express = require 'express'
cors = require 'cors'
fs = require 'fs'
path = require 'path'

# 
# Middleware
#
app = express()
app.use(express.logger('dev'))
app.use(cors())
app.use(express.bodyParser({}))


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
	response.send 'sup'

app.put '/upload/:cid', (request, response) ->
	{cid} = request.params

	UploadedImagePersistance.findOrCreateByCid cid, (err, uploadedImage) ->
		# TODO handle multiple files
		uploadedFile = request.files.image

		if uploadedFile
			console.log 'got file!'
			#console.log uploadedFile
			# TODO check not overwriting a file
			# TODO check is actually an image file
			isValidImageFile = true
			isNewRecord = true
			if isValidImageFile && isNewRecord
				oldPath = uploadedFile.path
				newPath = path.join(__dirname, "../app/images/uploads", uploadedImage.id)
				console.log 'renaming file %s -> %s', oldPath, newPath
				fs.rename(oldPath, newPath)
				uploadedImage.path = newPath
				UploadedImagePersistance.save(uploadedImage)
				

		response.send JSON.stringify(uploadedImage)
	

#
# Run
#
app.listen(4000)
module.exports = app
