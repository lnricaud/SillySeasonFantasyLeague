class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :password_digest
      t.string :team_name
      t.integer :league_id
      t.integer :money
      t.timestamps null: false
    end
  end
end
