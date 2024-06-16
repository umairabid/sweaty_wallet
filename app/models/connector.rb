class Connector < ApplicationRecord
  BANK_NAMES = { rbc: 'Royal Bank of Canada' }.with_indifferent_access
  enum bank: { 1 => 'rbc' }
  enum auth_type: { 1 => 'persisted', 2 => 'transient' }, _prefix: :auth_type
  belongs_to :user

  validates :bank, presence: true
  validates :auth_type, presence: true
  validates :username, presence: true
  validates :password, presence: true
end
