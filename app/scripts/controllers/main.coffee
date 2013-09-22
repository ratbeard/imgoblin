# http://html5demos.com/dnd-upload

if /imgoblin/.test(window.location)
	serverUrl = "http://imgoblin-api.mikefrawley.com"
else
	serverUrl = "http://localhost:7777"
	
app = angular.module('imgoblin')

app.controller 'MainCtrl',
	class MainCtrl
		allowedFileTypeRegex: /^image\/(png|jpeg|gif)$/i

		# State
		isUploadMessageVisible: false
		uploadsName: null
		
		@$inject: ['$http', '$scope', '$timeout', 'ImagePersistance']
		constructor: (@$http, @$scope, $timeout, @imagePersistance) ->
			window.c = @
			#$timeout =>
				#@isUploadMessageVisible = true
			#, 2000

		onFileDrop: (file) ->
			if !@allowedFileTypeRegex.test(file.type)
				throw "Bad FileType: #{file.type}"

			# Render preview thumbnail and show speech bubble
			reader = new window.FileReader
			reader.onload = (e) =>
				@$scope.$apply =>
					@isUploadMessageVisible = true
					@preview = e.target.result
			reader.readAsDataURL(file)

			# Upload image
			onSuccess = -> console.log ':)'
			onError = -> console.log ':('
			@imagePersistance.uploadImage(file)
				.success(onSuccess)
				.error(onError)

		saveUploadsName: ->
			onSuccess = -> console.log ':)'
			onError = -> console.log ':('
			@imagePersistance.saveNameForLastUpload(@uploadsName)
				.success(onSuccess)
				.error(onError)


# Shared service to show/hide the image gallery popup.
# Used by the routing layer, and the controller.
app.service 'GalleryPopupAPI', ['$timeout', ($timeout) ->
	return {
		isVisible: false
		hide: ->
			$timeout =>
				@isVisible = false
		show: ->
			$timeout =>
				@isVisible = true
	}
]

app.directive 'imageGalleryPopup', ['GalleryPopupAPI', (GalleryPopupAPI) ->
	return {
		controller: ($scope, ImagePersistance, GalleryPopupAPI) ->
			$scope.api = GalleryPopupAPI

			ImagePersistance.getImages()
				.success (images) ->
					$scope.images = images
				.error (r) ->
					console.log ':(', r

		#link: (scope, element, attributes) ->
			#scope.GalleryPopupAPI.
	}

]

app.directive 'goblin', ['$timeout', ($timeout) ->
	return {
		#restrict: 'E'
		link: (scope, element, attributes) ->
			# HACK - remove class that hides initial show/hide animation
			$timeout ->
				document.body.className = ''
			
	}
]

			
app.directive 'goblinDragContainer', [() ->
	return {
		link: (scope, element, attributes) ->
			window.s = scope
			controller = scope.main
			console.log 'goblinDragContainer', @

			# TODO handle multiple enter events being fired
			onDragEnter = (e) ->
				console.log 'dragenter', e
				element.addClass('dragging')

			# Prevent default to allow upcoming drop event
			onDragOver = (e) ->
				e.preventDefault()

			# Get single file and pass to controller
			onDrop = (e) ->
				e.preventDefault()
				element.removeClass('dragging')
				file = e.dataTransfer.files[0]
				scope.$apply ->
					controller.onFileDrop(file)

			element.addClass('goblin-drag-container')

			# TODO - get latest jqlite to get `on()`?
			element[0].ondragenter = onDragEnter
			element[0].ondragover = onDragOver
			element[0].ondrop  = onDrop

	}
]

app.service 'ImagePersistance', ["$http", ($http) ->
	return {
		lastUploadId: null

		generateUploadId: ->
			Math.random() * 1000000 | 0

		uploadImage: (file) ->
			id = @lastUploadId = @generateUploadId()
			url = "#{serverUrl}/upload/#{id}"
			console.log 'saveImage', url

			formData = new window.FormData()
			formData.append('image', file)
			$http.put(url, formData)

		saveNameForLastUpload: (name) ->
			saveNameForImage(@lastUploadId, name)

		saveNameForImage: (imageId, name) ->
			url = "#{serverUrl}/upload/#{imageId}"
			console.log 'saveName', url, name
			$http.put(url, {name})

		getImages: () ->
			url = "#{serverUrl}/images.json"
			$http.get(url)
	}
]


# Old manual xhr code, prob needed to show progress
#xhr = new XMLHttpRequest
#xhr.open("PUT", url)
#xhr.onload = => @showProgress(1)
#xhr.upload.onprogress = @onProgress
#xhr.send(formData)

#onProgress: (e) =>
	#return unless e.lengthComputable
	#@showProgress(e.loaded / e.total)

#showProgress: (fractionComplete) ->
	#x = fractionComplete * 100 | 0
	#console.log x

