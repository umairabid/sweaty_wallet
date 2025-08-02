require "factory_bot_rails"

# invoke like <rake "seeds:new_test_user[umair_test@email.com, Password123]">
namespace :seeds do
  desc "Seed User for Testing"
  task :new_test_user, [:email, :password] => :environment do |t, args|
    Seeds::NewTestUser.call(args[:email], args[:password])
  end
end
