class Transaction < ApplicationRecord
  include SoftDeletable

  DIMENSION_COUNT = 768


  COLUMNS = {
    'id' => { label: 'ID', value: ->(t) { t.id } },
    'date' => { label: 'Date', value: ->(t) { t.date.strftime('%d %b %Y') } },
    'external_id' => { label: 'External ID', value: ->(t) { t.external_id } },
    'description' => { label: 'Description', value: ->(t) { t.description } },
    'amount' => { label: 'Amount', value: ->(t) { t.amount } },
    'type' => { label: 'Type', value: ->(t) { t.is_credit ? 'Credit' : 'Debit' } },
    'category_name' => { label: 'Category', value: ->(t) { t.category&.name || 'Uncategorized' } },
    'account_name' => { label: 'Account', value: ->(t) { t.account.name } },
    'bank_name' => { label: 'Bank', value: ->(t) { t.account.connector.bank_name } },
    'suggested_category' => { label: 'Suggested Category', value: ->(t) { t.suggested_category&.name } }
  }.freeze

  DEFAULT_COLUMNS = %w[date description amount type category_name account_name].freeze

  belongs_to :account
  belongs_to :category, optional: true
  belongs_to :suggested_category, class_name: 'Category', optional: true
  has_neighbors :embedding, normalize: true, dimensions: Transaction::DIMENSION_COUNT


  has_many :to_transaction_neighbors, class_name: 'TransactionNeighbor'
  has_many :from_transaction_neighbors, foreign_key: 'neighbor_id', class_name: 'TransactionNeighbor'

  has_many :to_neighbors, through: :to_transaction_neighbors, source: :neighbor
  has_many :from_neighbors, through: :from_transaction_neighbors, source: :entry

  validates :external_id, uniqueness: { scope: :account }

  scope :exclude_transfers, lambda {
    where.not(parent_category: { code: 'transfers' })
      .left_joins(category: :parent_category)
  }

  def reset_neighbors!
    to_transaction_neighbors.destroy_all
    neighbors = nearest_neighbors(:embedding, distance: 'cosine').where.not(category: nil).first(5)
    to_transaction_neighbors.create!(neighbors.map { |n| {neighbor: n} })
  end
end

