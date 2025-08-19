class AddAuthMethodToConnectors < ActiveRecord::Migration[7.1]
  def up
    change_table :connectors do |t|
      t.change :username, :string, null: true
      t.change :password, :string, null: true
      t.column :auth_method, :integer, null: false, default: 1
    end
  end

  def down
    change_table :connectors do |t|
      t.change :username, :string, null: false  # Reverse null change
      t.change :password, :string, null: false  # Reverse null change
      t.remove :auth_method # Remove the column
    end
  end
end
