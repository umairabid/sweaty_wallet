require 'rails_helper'

describe Category, type: :class do
  let(:user) { create(:user) }
  let(:subject) { create(:category, user: user) }

  describe 'save' do
    context 'when creating category' do
      it 'automatically sets the code' do
        expect(subject.code).to eq('personal_expenses')
      end
    end

    context 'when updating category' do
      it 'does not update code' do
        subject.name = 'New Category'
        subject.save!
        expect(subject.code).to eq('personal_expenses')
      end
    end
  end
end
