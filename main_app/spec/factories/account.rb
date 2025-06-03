FactoryBot.define do
  factory :account do
    account_type { 'deposit_account' }
    external_id { SecureRandom.uuid }
    name { 'Chequing Account' }
    balance { 1258.26 }
    is_active { true }
    currency { 'CAD' }
  end

  factory :account_with_transactions, parent: :account do
    transient do
      transactions_count { 5 }
    end

    after(:create) do |account, evaluator|
      create_list(:transaction, evaluator.transactions_count, account:)
    end
  end
end
