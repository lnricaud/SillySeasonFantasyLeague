class CreatePlayerdata < ActiveRecord::Migration
  def change
    create_table :playerdata do |t|
    	t.string :data
    	t.integer :json_id
      t.timestamps null: false
    end
  end
end
