class Transaction < ApplicationRecord
  belongs_to :account

  validates :external_id, uniqueness: { scope: :account }
end
