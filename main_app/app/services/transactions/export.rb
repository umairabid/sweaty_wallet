class Transactions::Export
  include Callable
  include Exportable

  def columns
    {
      date: 'date',
      external_id: 'external_id',
      description: 'description',
      amount: 'amount',
      is_credit: 'is_credit',
      external_account_id: 'account.external_id',
      account_type: 'account.account_type',
      account_name: 'account.name',
      currency: 'account.currency',
      bank: 'account.connector.bank'
    }
  end
end
