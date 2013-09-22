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
	


# Not in angular yet, but probably soon
# http://stackoverflow.com/questions/14859266/input-autofocus-attribute/14859639#14859639
angular.module("ng").directive "ngFocus", ($timeout) ->
	link: (scope, element, attrs) ->
		scope.$watch(attrs.ngFocus, (val) ->
			if angular.isDefined(val) && val
				$timeout -> element[0].focus()
		)

