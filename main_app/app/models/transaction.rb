class Transaction < ApplicationRecord
  COLUMNS = {
    "id" => { label: "ID", value: ->(t) { t.id } },
    "date" => { label: "Date", value: ->(t) { t.date.strftime("%d %b %Y") } },
    "external_id" => { label: "External ID", value: ->(t) { t.external_id } },
    "description" => { label: "Description", value: ->(t) { t.description } },
    "amount" => { label: "Amount", value: ->(t) { t.amount } },
    "type" => { label: "Type", value: ->(t) { t.is_credit ? "Credit" : "Debit" } },
    "category_name" => { label: "Category", value: ->(t) { t.category&.name || "Uncategorized" } },
    "account_name" => { label: "Account", value: ->(t) { t.account.name } },
    "bank_name" => { label: "Bank", value: ->(t) { t.account.connector.bank_name } },
  }

  DEFAULT_COLUMNS = %w(date description amount type category_name account_name)

  belongs_to :account
  belongs_to :category, optional: true

  validates :external_id, uniqueness: { scope: :account }

  default_scope { where(deleted_at: nil).preload(:category) }

  scope :exclude_transfers, -> {
          where.not(parent_category: { code: "transfers" })
            .left_joins(category: :parent_category)
        }

  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def deleted?
    deleted_at.present?
  end
end
