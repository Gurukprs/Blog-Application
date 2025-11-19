require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'associations' do
    it { should belong_to(:topic) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  describe 'database' do
    it 'has a topic_id foreign key' do
      topic = create(:topic)
      post = create(:post, topic: topic)
      expect(post.topic_id).to eq(topic.id)
    end
  end

  describe 'scopes and methods' do
    let(:topic) { create(:topic) }
    let!(:post1) { create(:post, topic: topic, created_at: 2.days.ago) }
    let!(:post2) { create(:post, topic: topic, created_at: 1.day.ago) }
    let!(:post3) { create(:post, topic: topic, created_at: Time.current) }

    it 'orders posts by created_at descending' do
      posts = topic.posts.order(created_at: :desc)
      expect(posts.first).to eq(post3)
      expect(posts.last).to eq(post1)
    end
  end

  describe 'valid post creation' do
    let(:topic) { create(:topic) }

    it 'creates a valid post with title and body' do
      post = build(:post, topic: topic, title: 'Test Post', body: 'Test Body')
      expect(post).to be_valid
      expect(post.save).to be true
    end
  end

  describe 'invalid post creation' do
    let(:topic) { create(:topic) }

    it 'is invalid without a title' do
      post = build(:post, topic: topic, title: nil)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a body' do
      post = build(:post, topic: topic, body: nil)
      expect(post).not_to be_valid
      expect(post.errors[:body]).to include("can't be blank")
    end

    it 'is invalid without a topic' do
      post = build(:post, topic: nil)
      expect(post).not_to be_valid
    end
  end

  describe 'post deletion' do
    let(:topic) { create(:topic) }
    let(:post) { create(:post, topic: topic) }

    it 'can be deleted' do
      post_id = post.id
      post.destroy
      expect(Post.find_by(id: post_id)).to be_nil
    end
  end
end

