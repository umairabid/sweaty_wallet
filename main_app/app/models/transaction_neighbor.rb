class TransactionNeighbor < ApplicationRecord
  belongs_to :entry, class_name: 'Transaction', foreign_key: 'transaction_id'
  belongs_to :neighbor, class_name: 'Transaction', foreign_key: 'neighbor_id'
end
