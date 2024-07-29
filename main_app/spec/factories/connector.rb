FactoryBot.define do
  factory :connector do
    bank { "rbc" }
    auth_type { "transient" }
    status { "connected" }
  end
end
