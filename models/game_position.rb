require 'active_record'

class Game_position < ActiveRecord::Base
	serialize :positions

	def delete position
		key = self.positions.key(position)
		self.positions.delete(key)
		self.save
	end
	
end