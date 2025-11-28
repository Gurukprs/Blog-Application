class Rating < ApplicationRecord
  belongs_to :post

  validates :stars, presence: true, inclusion: { in: 1..5 }
end

