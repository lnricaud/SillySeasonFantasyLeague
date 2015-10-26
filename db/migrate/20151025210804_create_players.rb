class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :data
      t.integer :value
      t.integer :user_id
      t.integer :league_id

      t.timestamps null: false
    end
  end
end