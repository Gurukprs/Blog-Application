class Post < ApplicationRecord
  belongs_to :topic
  validates :title, presence: true
  validates :body, presence: true
end
