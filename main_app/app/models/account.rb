class Account < ApplicationRecord
  enum account_type: { credit_card: 1, deposit_account: 2, investment: 3, credit_line: 4, mortgage: 5 }
  validates :external_id, uniqueness: { scope: :connector }

  belongs_to :connector
  has_many :transactions
end
