FactoryBot.define do
  factory :connector do
    user { create(:user) }
    bank { "rbc" }
    auth_type { "transient" }
    status { "connected" }
  end
end
