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
      .select do |t|
      !existing_transactions_by_external_id[t[:external_id]] &&
        !existing_transactions_by_secondary_external_id[t[:secondary_external_id]]
    end
      .map do |t|
      amount = t[:amount].class == String ? t[:amount].tr(",", "").to_d : t[:amount]

      {
        external_id: t[:external_id],
        secondary_external_id: t[:secondary_external_id],
        description: t[:description],
        date: t[:date],
        is_credit: t[:type].downcase == "credit",
        amount: amount < 0 ? amount.abs : amount,
        external_object: t[:external_object],
      }
    end
  end

  def existing_transactions_by_external_id
    @existing_transactions_by_external_id ||= begin
        external_ids = @t_params.map { |t| t[:external_id] }
        @account.transactions.where(external_id: external_ids).index_by(&:external_id)
      end
  end

  def existing_transactions_by_secondary_external_id
    @existing_transactions_by_secondary_external_id ||= begin
        secondary_external_ids = @t_params.map { |t| t[:secondary_external_id] }.compact!
        @account.transactions.where(secondary_external_id: secondary_external_ids).index_by(&:secondary_external_id)
      end
  end
end
