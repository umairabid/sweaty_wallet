class AddEmbeddingToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :embedding, :vector, limit: 768 # dimensions
  end
end
