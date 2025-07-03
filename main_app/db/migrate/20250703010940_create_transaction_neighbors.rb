class CreateTransactionNeighbors < ActiveRecord::Migration[7.1]
  def change
    create_table :transaction_neighbors do |t|
      t.references :transaction, index: true, null: false
      t.references :neighbor, index: true, null: false, foreign_key: { to_table: :transactions }
      t.timestamps
    end
  end
end
