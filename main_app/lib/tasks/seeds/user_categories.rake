# invoke like <rake seeds:user_categories[3]> where 3 is user id
namespace :seeds do
  desc "Seed user categories"
  task :user_categories, [:user_id] => :environment do |t, args|
    user = User.find(args[:user_id])
    Categories::AddUserDefaultCategories.call(user)
  end
end
