Dir['./models/*.rb'].each {|f| require f }
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require File.expand_path '../../../mainController', __FILE__

class BasicTests < Minitest::Test
	include Rack::Test::Methods			

	def app
		MainController
	end

	def test_get_root
		get '/index'
		assert_equal 200, last_response.status
	end

	def test_get_404_one
		get '/asdad'
		assert_equal 404, last_response.status
	end

	def test_get_404_two
		get '/players/1/asdalksa'
		assert_equal 404, last_response.status
	end

	def test_get_redirect
		get '/'
		assert_equal 302, last_response.status
	end

	def test_get_index_logged_in
		get '/index' , {}, 'rack.session' => { :userid => 1 }
		assert last_response.redirect?
		follow_redirect!
		assert_equal 'http://example.org/players/1', last_request.url
	end

	def test_get_index_not_logged_in
		get '/index' 
		assert_equal 200, last_response.status
	end

	def test_post_login_wrong_method
		put '/login'
		assert_equal 404, last_response.status
	end

	def test_get_login_form
		get '/login'
		assert_equal 200, last_response.status
	end

	def test_post_login_wrong_parameters
		post '/login', {:username => "pepe", :no_valid_key => "password"}
		assert_equal 400, last_response.status
	end

	def test_post_login_valid_parameters_valid_user
		player = Player.create(name: "nuevo",username: "nuevo", password: "1234")
		post '/login', {:username => "nuevo", :password => "1234"}, 'rack.session' => {}
		assert last_response.redirect?
		follow_redirect!
		assert_equal 'http://example.org/players/' + player.id.to_s, last_request.url
		Player.delete_all
	end

	def test_post_login_valid_parameters_invalid_user
		Player.create(name: "pablo",username: "pablito", password: "1234")
		post '/login', {:username => "pepito", :password => "1234"}
		assert_equal 403, last_response.status
		Player.delete_all
	end

end
