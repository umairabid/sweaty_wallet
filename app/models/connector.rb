class Connector < ApplicationRecord
  BANK_NAMES = { rbc: 'Royal Bank of Canada' }.with_indifferent_access
  enum bank: { rbc: 1 }
  enum auth_type: { persisted: 1, transient: 2 }, _prefix: :auth_type
  enum status: { connecting: 1, failed: 2, connected: 3 }, _prefix: :status
  belongs_to :user

  validates :bank, presence: true
  validates :auth_type, presence: true
  validates :username, presence: true
  validates :password, presence: true
end
