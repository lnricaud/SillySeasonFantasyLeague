class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :action
      t.integer :game_week
      t.integer :user_id
      t.integer :player_id
      t.integer :league_id
      t.integer :value
      t.timestamps null: false
    end
  end
end
