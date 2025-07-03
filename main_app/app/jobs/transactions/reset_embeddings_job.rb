class Transactions::ResetEmbeddingsJob < ApplicationJob
  queue_as :default

  def perform(transactions)
    transactions.each do |t|
      t.embedding = nil
      t.suggested_category_id = nil
      t.from_neighbors.each(&:reset_neighbors!)
    end
    Transactions::UpdateEmbeddings.call(transactions)
  end
end
