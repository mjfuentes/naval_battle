class CreateGamesTwo < ActiveRecord::Migration
  	def change
		create_table :games do |t|
			t.integer :creator
	      	t.integer :rival
	      	t.string  :size
	  	end
	end
end