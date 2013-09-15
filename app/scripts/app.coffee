app = angular.module("imgoblin", [
	'ui.router'
	'ngAnimate'
])

app.config(($stateProvider, $urlRouterProvider) ->
	$stateProvider
		.state("main",
			url: "/main"
			templateUrl: "views/main.html"
		)
		.state("gallery",
			url: "/gallery"
			templateUrl: "views/image-gallery.html"
		)

	# Default route
	$urlRouterProvider.otherwise("/main")
)
	
