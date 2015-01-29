class CreateGamePositions < ActiveRecord::Migration
  def change
  	create_table :game_positions do |t|
		t.integer :user_id
      	t.integer :game_id
      	t.text :positions
  	end
  end
end
