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
      .select { |t| existing_transactions_by_external_id[t[:external_id]].blank? }
      .select { |t| !(t[:secondary_external_id].present? && existing_transactions_by_secondary_external_id[t[:secondary_external_id].present?]) }
      .map do |t|
      amount = t[:amount].class == String ? t[:amount].tr(',', '').to_d : t[:amount]

      {
        external_id: t[:external_id],
        secondary_external_id: t[:secondary_external_id],
        description: t[:description],
        date: t[:date],
        is_credit: t[:is_credit].nil? ? t[:type].downcase == 'credit' : t[:is_credit],
        amount: amount < 0 ? amount.abs : amount,
        external_object: t[:external_object]
      }
    end
  end

  def existing_transactions_by_external_id
    @existing_transactions_by_external_id ||= begin
      external_ids = @t_params.map { |t| t[:external_id] }
      @account.transactions.unscoped.where(external_id: external_ids)
        .map { |t| [t.external_id, t.id] }
        .to_h
    end
  end

  def existing_transactions_by_secondary_external_id
    @existing_transactions_by_secondary_external_id ||= begin
      secondary_external_ids = @t_params.map { |t| t[:secondary_external_id] }.compact!
      @account.transactions.unscoped.where(secondary_external_id: secondary_external_ids)
        .map { |t| [t.secondary_external_id, t.id] }
        .to_h
    end
  end
end
