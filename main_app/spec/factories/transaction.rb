FactoryBot.define do
  factory :transaction do
    external_id { SecureRandom.uuid }
    secondary_external_id { "secondary_transaction_external_id" }
    description { "Transction description" }
    date { Time.zone.now.to_date }
    amount { BigDecimal(SecureRandom.random_number(100)) }
  end
end
