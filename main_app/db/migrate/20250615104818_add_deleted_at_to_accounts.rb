class AddDeletedAtToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :deleted_at, :datetime
  end
end
