# frozen_string_literal: true

class Connector < ApplicationRecord
  BANK_NAMES = { rbc: 'Royal Bank of Canada', td: 'TD Bank' }.with_indifferent_access
  enum bank: { rbc: 1, td: 2 }
  enum auth_type: { persisted: 1, transient: 2 }, _prefix: :auth_type
  enum status: { connecting: 1, failed: 2, connected: 3 }, _prefix: :status
  belongs_to :user

  validates :bank, presence: true
  validates :auth_type, presence: true
  validates :username, presence: true
  validates :password, presence: true
end
