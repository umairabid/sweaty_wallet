class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :nullify
  belongs_to :parent_category, class_name: "Category", optional: true

  before_create :set_code
  before_update :restore_code

  validates :name, presence: true

  def restore_code
    self.code = code_was
  end

  def set_code
    self.code = name.downcase.gsub(/\s+/, "_")
  end
end
