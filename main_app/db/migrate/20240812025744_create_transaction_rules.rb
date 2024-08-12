class CreateTransactionRules < ActiveRecord::Migration[7.1]
  def change
    create_table :transaction_rules do |t|
      t.string :name, null: false
      t.references :category, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.jsonb :conditions, default: nil
      t.timestamps
    end
  end
end
