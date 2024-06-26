class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.integer :type, null: false
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :nick_name
      t.decimal :balance, null: false, default: 0.00
      t.boolean :is_active, null: false, default: false
      t.string :currency, null: false
      t.references :users, index: true, null: false
      t.references :connectors, index: true, null: false
      t.timestamps
    end
  end
end
