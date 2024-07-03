class Connector < ApplicationRecord
  BANK_NAMES = { rbc: 'Royal Bank of Canada', td: 'TD Bank' }.with_indifferent_access
  enum bank: { rbc: 1, td: 2 }
  enum auth_type: { persisted: 1, transient: 2 }, _prefix: :auth_type
  enum status: { connecting: 1, failed: 2, connected: 3 }, _prefix: :status
  enum auth_method: { extension: 1, direct: 2 }, _prefix: :auth_method
  
  belongs_to :user
  has_many :accounts

  validates :bank, presence: true
  validates :auth_type, presence: true
end
