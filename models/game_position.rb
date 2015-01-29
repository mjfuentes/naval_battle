require 'active_record'

class Game_position < ActiveRecord::Base
	serialize :positions

end