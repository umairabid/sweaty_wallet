class Connector < ApplicationRecord
  BANK_NAMES = { rbc: 'Royal Bank of Canada' }.with_indifferent_access
  enum bank: { 1 => 'rbc' }
  belongs_to :user
end
