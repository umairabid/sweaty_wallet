class Transactions::Export
  include Callable
  include Broadcastable
  include Exportable

  def columns
    {
      external_id: 'external_id',
      description: 'description',
      amount: 'amount',
      is_credit: 'is_credit',
      external_account_id: 'accounts.external_id',
      account_type: 'accounts.account_type',
      account_name: 'accounts.name',
      currency: 'accounts.currency',
      bank: 'accounts.connectors.name',
    }
  end
end