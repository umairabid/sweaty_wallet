class Imports::ImportTransactions
  include Callable

  def initialize(account, t_params)
    @account = account
    @t_params = t_params
  end

  def call
    persist!
  end

  def persist!
    @account.transactions.create!(new_transaction_params)
  end

  def new_transaction_params
    @t_params
      .select { |t| !existing_transactions[t[:external_id]] }
      .map do |t|
        {
          external_id: t[:external_id],
          description: t[:description],
          date: t[:date],
          is_credit: t[:type] == 'credit',
          amount: t[:amount].class == String ? t[:amount].tr(",", "").to_d : t[:amount]
        }
    end
  end

  def existing_transactions
    external_ids = @t_params.map { |t| t[:external_id] }
    @account.transactions.where(external_id: external_ids).index_by(&:external_id)
  end
end
