require 'active_record'

class Game < ActiveRecord::Base
 	before_save :default_values

	def default_values
    	self.status ||= 0
    	self.turn ||= 0
    	self.winner ||= 0
    	self.loser ||= 0
  	end

	def start
		self.status = 1
		self.turn = self.creator
		self.save
	end

	def end winner
		self.status = 2
		self.winner = winner
		if (winner == self.creator) then
			self.loser = self.rival
		else
			self.loser = self.creator
		end
		self.save
	end

	def move_made
		if self.turn == self.creator then
			self.turn = self.rival
		else
			self.turn = self.creator
		end
		self.save
	end

end	