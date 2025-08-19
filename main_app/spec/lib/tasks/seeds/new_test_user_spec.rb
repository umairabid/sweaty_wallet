require 'rails_helper'
require 'rake'
SweatyWallet::Application.load_tasks

describe 'seeds:new_test_user', type: :seed_task do
  it 'seeds user' do
    Rake::Task['seeds:new_test_user'].execute({ email: 'test@example.com', password: '123456' })
    expect(User.where(email: 'test@example.com').count).to eq(1)
  end
end
