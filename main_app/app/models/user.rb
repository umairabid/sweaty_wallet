class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  after_commit :create_categories, on: [:create, :update]

  has_many :connectors, dependent: :destroy
  has_many :accounts, through: :connectors
  has_many :transactions, through: :accounts, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :transaction_rules, dependent: :destroy
  has_many :file_imports, dependent: :destroy
  has_many_attached :transaction_exports

  has_one_attached :avatar

  validates :name, presence: true

  private

  def create_categories
    Categories::AddUserDefaultCategories.call(self)
  end
end
