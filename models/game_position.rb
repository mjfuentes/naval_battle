require 'active_record'

class Game_position < ActiveRecord::Base
	serialize :positions

	def delete position
		key = self.positions.key(position)
		self.positions.delete(key)
		self.save
	end

	def hit? position
		if (self.positions.has_value?(position)) then
			self.delete(position)
			true
		else
			false
		end
	end

	def done? 
		self.positions.length == 0
	end
	
end