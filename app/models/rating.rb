class Rating < ApplicationRecord
  belongs_to :post

  validates :stars, presence: true, inclusion: { in: 1..5 }

  after_save :update_post_rating_average
  after_destroy :update_post_rating_average

  private

  def update_post_rating_average
    avg = post.ratings.average(:stars)
    post.update_column(:rating_average, avg&.to_f)
  end
end

