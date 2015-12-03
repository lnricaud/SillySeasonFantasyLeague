class AddTopbidToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :topbid, :integer
  end
end
