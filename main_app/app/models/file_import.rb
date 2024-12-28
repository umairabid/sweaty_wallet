class FileImport < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  enum status: { pending: 1, processing: 2, success: 3, failed: 4 }
end
