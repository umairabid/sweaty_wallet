class Asset < ApplicationRecord
  ASSET_TYPES = {
    real_estate: 'Real Estate',
    vehicle: 'Vehicle',
    loan: 'Loan',
    investment: 'Investment',
    other_asset: 'Other Asset',
    other_liability: 'Other Liability'
  }

  POSITIVE_ASSET_TYPES = %i[real_estate vehicle investment other_asset].freeze

  LIABILITY_ASSET_TYPES = %i[load other_liability].freeze

  belongs_to :user

  validates :name, presence: true
  validates :value, presence: true, numericality: true
  enum asset_type: { real_estate: 0, vehicle: 1, loan: 2, investment: 3, other_asset: 4,
                     other_liability: 5 }

  def asset_label
    ASSET_TYPES[asset_type.to_sym]
  end
end
