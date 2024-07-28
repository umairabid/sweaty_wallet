class Category < ApplicationRecord
  belongs_to :user

  before_create :set_code
  before_update :restore_code

  def restore_code
    self.code = code_was
  end

  def set_code
    self.code = name.downcase.gsub(/\s+/, "_")
  end
end
