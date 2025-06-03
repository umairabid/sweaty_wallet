FactoryBot.define do
  factory :asset do
    description { 'Asset description' }
    name { 'Asset name' }
    value { BigDecimal(SecureRandom.random_number(100)) }
  end
end
