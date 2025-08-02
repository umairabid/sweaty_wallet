class AddAccountConnectorIdExternalIdUniqueIndex < ActiveRecord::Migration[7.1]
  def change
    add_index :accounts, [:connector_id, :external_id], unique: true
  end
end
