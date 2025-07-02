class Transaction < ApplicationRecord
  include SoftDeletable

  DIMENSION_COUNT = 768

  has_neighbors :embedding, normalize: true, dimensions: Transaction::DIMENSION_COUNT

  COLUMNS = {
    'id' => { label: 'ID', value: ->(t) { t.id } },
    'date' => { label: 'Date', value: ->(t) { t.date.strftime('%d %b %Y') } },
    'external_id' => { label: 'External ID', value: ->(t) { t.external_id } },
    'description' => { label: 'Description', value: ->(t) { t.description } },
    'amount' => { label: 'Amount', value: ->(t) { t.amount } },
    'type' => { label: 'Type', value: ->(t) { t.is_credit ? 'Credit' : 'Debit' } },
    'category_name' => { label: 'Category', value: ->(t) { t.category&.name || 'Uncategorized' } },
    'account_name' => { label: 'Account', value: ->(t) { t.account.name } },
    'bank_name' => { label: 'Bank', value: ->(t) { t.account.connector.bank_name } }
  }.freeze

  DEFAULT_COLUMNS = %w[date description amount type category_name account_name].freeze

  belongs_to :account
  belongs_to :category, optional: true

  validates :external_id, uniqueness: { scope: :account }

  scope :exclude_transfers, lambda {
    where.not(parent_category: { code: 'transfers' })
      .left_joins(category: :parent_category)
  }
end
