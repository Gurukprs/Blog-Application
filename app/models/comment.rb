class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  
  # has_many through association for comment ratings
  has_many :user_comment_ratings, dependent: :destroy
  has_many :raters, through: :user_comment_ratings, source: :user

  validates :body, presence: true
end
