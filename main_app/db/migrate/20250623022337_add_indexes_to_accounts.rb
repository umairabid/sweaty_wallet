class AddIndexesToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_index :accounts, :external_id, unique: true
    add_index :accounts, %i[connector_id is_active]
    add_index :accounts, %i[connector_id deleted_at]
    add_index :accounts, %i[connector_id external_id]
  end
end
