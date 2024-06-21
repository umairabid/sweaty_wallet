class AddStatusToConnectors < ActiveRecord::Migration[7.1]
  def change
    change_table :connectors do |t|
      t.integer :status, null: false, index: true, default: 1
      t.string :two_factor_key
    end
  end
end
