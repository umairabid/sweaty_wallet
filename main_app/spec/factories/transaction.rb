FactoryBot.define do
  factory :transaction do
    external_id { SecureRandom.uuid }
    secondary_external_id { "secondary_transaction_external_id" }
    description { "Transction description" }
    date { Date.new }
    amount { BigDecimal(SecureRandom.random_number(100)) }
  end
end
