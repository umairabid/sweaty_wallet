FactoryBot.define do
  factory :user do
    name { 'John Doe' }
    email { 'user@email.com' }
    password { 'password123' }

    after(:build) do |user|
      user.skip_confirmation!
    end
  end
end
