class Transactions::SetSuggestedCategories
  include Callable

  def initialize(user, transaction_ids)
    @user = user
    @transaction_ids = transaction_ids
  end

  def call
    chat = RubyLLM.chat.with_params(generationConfig: schema)
    content = chat.ask(prompt).content
    suggestions = JSON.parse(content)
    transactions_by_id = transactions.index_by(&:id)
    suggestions.each do |suggestion|
      transaction = transactions_by_id[suggestion['id']]
      transaction.suggested_category = categories_by_code[suggestion['category']]
      transaction.save!
    end
  end

  def schema
    {
      responseMimeType: 'application/json',
      responseSchema: {
        type: 'ARRAY',
        items: {
          type: 'OBJECT',
          properties: {
            id: { type: 'NUMBER' },
            category: { type: 'STRING' }
          }
        }
      }
    }
  end

  def categories_by_code
    @categories_by_code ||= @user.categories.index_by(&:code)
  end

  def transactions_prompt
    transactions.map do |transaction|
      {
        id: transaction.id,
        description: transaction.description,
        neighbors: transaction.to_neighbors.map do |neighbor|
          {
            description: neighbor.description,
            category: neighbor.category.code
          }
        end
      }
    end
  end

  def transactions
    @transactions ||= @user.transactions
      .where(id: @transaction_ids, suggested_category: nil)
      .preload(to_neighbors: :category)
  end

  def prompt
    <<~PROMPT
      I am providing you with the user categories and transaction descriptions that needs to be categorized in one of user categories
      To set the context, with each description I will provide you transaction_id, to identify transaction and neighbors that are#{' '}
      closest to the description and are already categorized, each transaction will be in the following format
      { id: 1, description: 'Walmart Charge', neighbors: [ {description: 'Other Walmart Charge', category: 'groceries'} ] }

      Here are user categories
      #{categories_by_code.keys.join("\n")}

      Here are transactions
      #{transactions_prompt}
    PROMPT
  end
end
