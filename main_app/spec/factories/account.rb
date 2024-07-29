FactoryBot.define do
  factory :account do
    account_type { "deposit_account" }
    external_id { "deposit_account_bank_id" }
    name { "Chequing Account" }
    balance { 1258.26 }
    is_active { true }
    currency { "CAD" }
  end
end
