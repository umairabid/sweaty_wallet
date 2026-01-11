class Connector < ApplicationRecord
  BANKS_CONFIG = {
    rbc: {
      name: 'Royal Bank of Canada',
      icon: 'rbc',
      color: '#006AC3',
      text_color: '#fff'
    },
    td: {
      name: 'TD Canada Trust',
      icon: 'td',
      color: '#008a00',
      text_color: '#fff'
    },
    walmart_mc: {
      name: 'Walmart Master Card',
      icon: 'walmart',
      color: '#ffc220',
      text_color: '#fff'
    },
    cibc: {
      name: 'Canadian Imperial Bank of Commerce (CIBC)',
      icon: 'cibc',
      color: '#dee9f7',
      text_color: '#8b1d41'
    },
    example_bank: {
      name: 'Example Bank',
      icon: 'example_bank',
      color: '#ff5733',
      text_color: '#ffffff'
    }
  }.with_indifferent_access

  enum :bank, { rbc: 1, td: 2, walmart_mc: 3, cibc: 4, example_bank: 5 }
  enum :auth_type, { persisted: 1, transient: 2 }, prefix: :auth_type
  enum :status, { connecting: 1, failed: 2, connected: 3 }, prefix: :status
  enum :auth_method, { extension: 1, direct: 2 }, prefix: :auth_method

  belongs_to :user
  has_many :accounts

  validates :bank, presence: true
  validates :auth_type, presence: true
  validates :username, presence: true, if: -> { auth_method == 'direct' }
  validates :password, presence: true, if: -> { auth_method == 'direct' }

  def bank_name
    BANKS_CONFIG[bank][:name]
  end

  def bank_icon
    BANKS_CONFIG[bank][:icon]
  end

  def bank_brand_color
    BANKS_CONFIG[bank][:color]
  end

  def bank_text_color
    BANKS_CONFIG[bank][:text_color]
  end

  def active_accounts
    accounts.where(is_active: true)
  end
end
