class Post < ApplicationRecord
  belongs_to :topic
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :title, presence: true
  validates :body, presence: true

  attr_writer :tag_names
  after_save :sync_tags

  def tag_names
    @tag_names || tags.pluck(:name).join(", ")
  end

  private

  def sync_tags
    return unless @tag_names

    names = @tag_names.split(",").map { |name| name.strip.downcase }.reject(&:blank?).uniq
    self.tags = names.map { |name| Tag.find_or_create_by(name: name) }
  end
end
