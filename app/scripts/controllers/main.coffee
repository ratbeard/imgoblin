
angular.module('imgoblin').controller('MainCtrl', ($scope) ->
	$scope.awesomeThings = [
		'HTML5 Boilerplate',
		'AngularJS',
		'Karma'
	]
)

# http://html5demos.com/dnd-upload
#
class FileDragUI
	constructor: (@container, @uploadUrl) ->
		
		# Events
		@container.ondragenter = @onDragEnter
		@container.ondragover = @onDragOver
		@container.ondrop = @onDrop

	onDragEnter: (e) =>
		@container.classList.add('dragging')

	onDragOver: (e) =>
		e.preventDefault()
	
	onDrop: (e) =>
		e.preventDefault()
		@container.classList.remove('dragging')

		@readfiles(e.dataTransfer.files)

	allowedFileType: (fileType) ->
		/^image\/(png|jpeg|gif)$/.test(fileType)

	previewFile: (file) ->
		if !@allowedFileType(file.type)
			console.error 'bad file type'
			return

		@previewContainer = document.querySelector(".holder")
		container = @previewContainer
		reader = new FileReader
		reader.onload = (e) =>
			image = new Image
			image.src = e.target.result
			image.width = 200
			container.appendChild(image)
		reader.readAsDataURL(file)

	readfiles: (files) ->
		formData = new window.FormData()
		for file in files
			console.log file
			formData.append('image', file)
			@previewFile(file)
		formData.append('smap', 'hat')

		url = @uploadUrl + "/" + generateCid()
		xhr = new XMLHttpRequest
		xhr.open("PUT", url)
		xhr.onload = => @showProgress(1)
		xhr.upload.onprogress = @onProgress
		xhr.send(formData)

	onProgress: (e) =>
		return unless e.lengthComputable
		@showProgress(e.loaded / e.total)

	showProgress: (fractionComplete) ->
		x = fractionComplete * 100 | 0
		console.log x
		

generateCid = ->
	"cid" + (Math.random() * 12354389 | 0)

container = document.querySelector('.drop-container')
url = "http://localhost:4000/upload"
new FileDragUI(container, url)
		
