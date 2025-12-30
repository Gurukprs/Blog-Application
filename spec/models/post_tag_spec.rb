require 'rails_helper'

RSpec.describe PostTag, type: :model do
  subject { create(:post_tag) }

  describe 'associations' do
    it { should belong_to(:post) }
    it { should belong_to(:tag) }
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:tag_id).scoped_to(:post_id) }
  end
end
