class AddLocationToTools < ActiveRecord::Migration[7.0]
  def change
    add_column :tools, :location, :string
  end
end
