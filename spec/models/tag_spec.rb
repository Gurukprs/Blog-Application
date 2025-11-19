require 'rails_helper'

RSpec.describe Tag, type: :model do
  subject { create(:tag, name: 'ruby') }

  describe 'associations' do
    it { should have_many(:post_tags).dependent(:destroy) }
    it { should have_many(:posts).through(:post_tags) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'normalization' do
    it 'downcases and strips the name before validation' do
      tag = create(:tag, name: '  RubyOnRails  ')
      expect(tag.name).to eq('rubyonrails')
    end
  end
end
