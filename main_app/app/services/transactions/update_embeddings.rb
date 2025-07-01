class Transactions::UpdateEmbeddings
  include Callable

  def initialize(transactions)
    @transactions = transactions
  end

  def call
    validate!
    @transactions.each_with_index do |transaction, index|
      transaction.embedding = embeddings.vectors[index]
      transaction.save!
    end
  end

  private

  def validate!
    msg = 'All transactions must have description and category'
    raise CustomerError, msg if @transactions.any? { |t| t.embedding.present? || t.description.blank? }
  end

  def descriptions
    @descriptions ||= @transactions.map(&:description)
  end

  def embeddings
    @embeddings ||= RubyLLM.embed(descriptions, dimensions: Transaction::DIMENSION_COUNT)
  end
end
