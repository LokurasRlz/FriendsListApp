class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.bigint :tool_id
      t.string :tool_code
      t.string :user_name
      t.text :description, null: false

      t.timestamps
    end

    add_index :events, :tool_id
  end
end
