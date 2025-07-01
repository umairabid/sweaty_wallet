class Transactions::UpdateEmbeddingsJob < ApplicationJob
  queue_as :default

  def perform
    Transaction.where(embedding: nil).where.not(description: nil).in_batches(of: 100) do |transactions|
      Transactions::UpdateEmbeddings.call(transactions)
    end
  end
end
