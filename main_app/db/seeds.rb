user = User.new(
  :name => "Test User",
  :email => "user@example.com",
  :password => "123456",
  :password_confirmation => "123456",
)
user.skip_confirmation!
user.save!
