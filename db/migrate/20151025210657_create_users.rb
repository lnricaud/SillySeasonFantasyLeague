class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :password_digest
      t.string :team_name
      t.integer :league_id
      t.integer :money, default: 100000000
      t.integer :gwpoints, default: 0
      t.integer :totpoints, default: 0
      t.timestamps null: false
    end
  end
end
