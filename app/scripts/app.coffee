angular.module("imgoblin", []).config ($routeProvider) ->
  $routeProvider
		.when("/",
			templateUrl: "views/main.html"
			controller: "MainCtrl"
		).when("/dempics",
			templateUrl: "views/image-gallery.html"
			controller: "ImageGalleryController"
  	).otherwise
			redirectTo: "/"

