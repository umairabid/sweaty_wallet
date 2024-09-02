class AddCategoryIdToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :transactions, :category, index: true, null: true, foreign_key: { on_delete: :nullify }
  end
end
