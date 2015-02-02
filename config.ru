require File.expand_path '../mainController', __FILE__
require File.expand_path '../gameController', __FILE__

map ('/players'){
	run GameController
}

map ('/'){
	run MainController
}