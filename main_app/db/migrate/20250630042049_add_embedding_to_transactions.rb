class AddEmbeddingToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :embedding, :vector, limit: 768 # dimensions
  end
end
