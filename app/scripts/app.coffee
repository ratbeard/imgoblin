app = angular.module("imgoblin", [
	'ui.router'
	'ngAnimate'
])

app.config(($stateProvider, $urlRouterProvider) ->
	$stateProvider
		.state(
			name: "main"
			url: "/o_0"
			templateUrl: "views/main.html"
		)
		.state(
			name: "main.image-gallery",
			url: "^/dempics"
			#controller: 'ImageGalleryController'
			onEnter: ['GalleryPopupAPI', (GalleryPopupAPI) ->
				console.log 'GALLERY'
				GalleryPopupAPI.show()
			]
			onExit: ['GalleryPopupAPI', (GalleryPopupAPI) ->
				GalleryPopupAPI.hide()
			]
		)

	# Default route
	$urlRouterProvider.otherwise("/o_0")
)
	
