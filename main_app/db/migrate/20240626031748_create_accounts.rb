class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.integer :account_type, null: false
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :nick_name
      t.decimal :balance, null: false, default: 0.00
      t.boolean :is_active, null: false, default: false
      t.string :currency, null: false
      t.references :connector, index: true, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
