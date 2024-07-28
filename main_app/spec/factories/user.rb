FactoryBot.define do
  factory :user do
    email { "user@email.com" }
    password { "password123" }

    after(:build) do |user|
      user.skip_confirmation!
    end
  end
end
