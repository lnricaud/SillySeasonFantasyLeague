class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :user_id
      t.integer :player_id
      t.integer :league_id
      t.integer :action
      t.integer :value
      t.integer :game_week

      t.timestamps null: false
    end
  end
end
