class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.string :league_name
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
