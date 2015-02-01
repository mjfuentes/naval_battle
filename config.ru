require File.expand_path '../app', __FILE__
require File.expand_path '../gameController', __FILE__

map ('/players'){
	run GameController
}

map ('/'){
	run Application
}