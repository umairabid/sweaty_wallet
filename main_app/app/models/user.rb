class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  has_many :connectors
  has_many :accounts, through: :connectors
  has_many :transactions, through: :accounts
  has_many :categories
  has_many :transaction_rules
  has_many_attached :transaction_exports
end
