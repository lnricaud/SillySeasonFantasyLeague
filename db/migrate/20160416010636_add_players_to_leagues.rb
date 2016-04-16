class AddPlayersToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :players, :string
  end
end
