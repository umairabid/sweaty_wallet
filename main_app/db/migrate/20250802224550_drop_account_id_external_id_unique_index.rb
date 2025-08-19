class DropAccountIdExternalIdUniqueIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :accounts, name: 'index_accounts_on_connector_id_and_external_id'
    remove_index :accounts, name: 'index_accounts_on_external_id'
  end
end
