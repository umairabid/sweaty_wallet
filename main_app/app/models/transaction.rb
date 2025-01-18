class Transaction < ApplicationRecord
  COLUMNS = {
    id: "ID",
    date: "Date",
    external_id: "External ID",
    description: "Description",
    amount: "Amount",
    type: "Type",
    category_name: "Category",
    account_name: "Account",
    bank_name: "Bank",
  }
  belongs_to :account
  belongs_to :category, optional: true

  validates :external_id, uniqueness: { scope: :account }
end
