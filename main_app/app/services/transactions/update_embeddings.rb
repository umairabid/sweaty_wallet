class Transactions::UpdateEmbeddings
  include Callable

  def initialize(transactions)
    @transactions = transactions
  end

  def call
    validate!
    update_embeddings!
    update_neighbors!
  end

  private

  def update_neighbors!
    @transactions.each(&:reset_neighbors!)
  end

  def update_embeddings!
    @transactions.each_with_index do |transaction, index|
      transaction.embedding = descriptions.size == 1 ? embeddings.vectors : embeddings.vectors[index]
      transaction.save!
    end
  end

  def validate!
    msg = 'All transactions must have description and no existing embedding.'
    raise CustomerError, msg unless transactions_valid?
  end

  def transactions_valid?
    @transactions.all? { |t| t.embedding.blank? || t.description.present? }
  end

  def descriptions
    @descriptions ||= @transactions.map(&:description)
  end

  def embeddings
    @embeddings ||= RubyLLM.embed(descriptions, dimensions: Transaction::DIMENSION_COUNT)
  end
end
