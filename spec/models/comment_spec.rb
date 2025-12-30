require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { should belong_to(:post) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'creation' do
    it 'is valid with a body and post' do
      post = create(:post)
      comment = build(:comment, post: post, body: 'Test comment')
      expect(comment).to be_valid
    end

    it 'is invalid without a body' do
      comment = build(:comment, body: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include("can't be blank")
    end
  end
end
