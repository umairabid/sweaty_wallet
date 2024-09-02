class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :category, optional: true

  validates :external_id, uniqueness: { scope: :account }
end
