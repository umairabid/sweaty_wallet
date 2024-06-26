class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :external_id, null: false
      t.string :description, null: false
      t.date :date, null: false
      t.boolean :is_credit, null: false, default: false
      t.decimal :amount, null: false, default: 0.00
      t.references :accounts, null: false, index: true
      t.timestamps
    end
  end
end
