serverUrl = "http://localhost:4000"


angular.module('imgoblin').controller 'MainCtrl', ($scope, $http) ->
	$scope.lastUploadCid = ''
	$scope.lastUploadName = 'cool'
	window.supesHacky = $scope

	$scope.submitLastUploadName = ->
		console.log 'a', $scope.lastUploadName
		cid = $scope.lastUploadCid
		name = $scope.lastUploadName
		url = serverUrl + "/upload/#{cid}"
		data = {name}
		console.log url, data
		$http.put(url, data)
			.success (r) ->
				console.log ":)", r
			.error (r) ->
				console.log ":(", r


angular.module('imgoblin').controller 'ImageGalleryController', ($scope, $http) ->
	$http.get(serverUrl + "/images.json")
		.success (images) ->
			$scope.images = images
		.error (r) ->
			console.log ':(', r




# http://html5demos.com/dnd-upload
#
class FileDragUI
	constructor: (@container, @serverUrl) ->
		
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

		cid = generateCid()
		url = @serverUrl + "/upload/" + cid
		xhr = new XMLHttpRequest
		xhr.open("PUT", url)
		xhr.onload = => @showProgress(1)
		xhr.upload.onprogress = @onProgress
		xhr.send(formData)

		supesHacky.$apply ->
			supesHacky.lastUploadCid = cid

	onProgress: (e) =>
		return unless e.lengthComputable
		@showProgress(e.loaded / e.total)

	showProgress: (fractionComplete) ->
		x = fractionComplete * 100 | 0
		console.log x
		

generateCid = ->
	"cid" + (Math.random() * 12354389 | 0)

container = document.querySelector('.drop-container')
new FileDragUI(container, serverUrl)
		
