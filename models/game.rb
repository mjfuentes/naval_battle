require 'active_record'

class Game < ActiveRecord::Base
	attr_accessor :state 

	def start
		@state = "started"
	end
end