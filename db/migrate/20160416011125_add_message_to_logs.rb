class AddMessageToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :message, :string
  end
end
