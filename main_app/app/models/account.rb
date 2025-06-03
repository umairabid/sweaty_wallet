class Account < ApplicationRecord
  ACCOUNT_TYPE_LABELS = {
    credit_card: 'Credit Card',
    deposit_account: 'Deposit/Chequing Account',
    investment: 'Investment',
    credit_line: 'Line of Credit',
    mortgage: 'Mortgage'
  }.freeze

  POSITIVE_ACCOUNTS = %i[deposit_account investment].freeze

  NEGATIVE_ACCOUNTS = %i[credit_card mortgage credit_line].freeze

  FILTERABLE_ACCOUNT_TYPES = %i[credit_card deposit_account].freeze

  enum account_type: { credit_card: 1, deposit_account: 2, investment: 3, credit_line: 4,
                       mortgage: 5 }
  validates :external_id, uniqueness: { scope: :connector }

  belongs_to :connector
  has_many :transactions

  def account_type_label
    ACCOUNT_TYPE_LABELS[account_type.to_sym]
  end

  def active?
    is_active
  end

  def other_accounts
    connector.active_accounts.where.not(id:).where(account_type:)
  end
end
