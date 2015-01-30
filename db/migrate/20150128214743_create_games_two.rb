class CreateGamesTwo < ActiveRecord::Migration
  	def change
		create_table :games do |t|
			t.integer :creator
	      	t.integer :rival
	      	t.string  :size
	      	t.integer :turn
	      	t.integer :status
	      	t.integer :winner
	      	t.integer :loser
	  	end
	end
end