class AddColumnToPlayers < ActiveRecord::Migration
  def change
  	add_column :players, :owned, :boolean
  end
end
