class Post < ApplicationRecord
  belongs_to :topic
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :ratings, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true
  validates :body, presence: true

  attr_accessor :pending_tag_names

  after_save :sync_pending_tags

  def tags_attributes=(attributes)
    self.pending_tag_names ||= []

    # attributes is a hash like { "0" => { "name" => "ruby" }, "1" => { "name" => "rails" } }
    attributes.each_value do |tag_params|
      name = tag_params["name"].to_s.strip.downcase
      next if name.blank?

      pending_tag_names << name
    end
  end

  def tag_names=(value)
    self.pending_tag_names ||= []
    normalized_names = value.to_s.split(",").map { |name| name.strip.downcase }.reject(&:blank?)
    self.pending_tag_names = (pending_tag_names + normalized_names).uniq
  end

  def tag_names
    tags.pluck(:name).join(", ")
  end

  private

  def sync_pending_tags
    return if pending_tag_names.blank?

    new_tags = pending_tag_names.uniq.map do |name|
      Tag.find_or_create_by(name: name)
    end

    # Add new tags to existing tags without overwriting
    # Create PostTag records directly to ensure they're saved
    existing_tag_ids = self.tags.pluck(:id)
    new_tags.each do |tag|
      unless existing_tag_ids.include?(tag.id)
        PostTag.find_or_create_by(post_id: self.id, tag_id: tag.id)
      end
    end
    
    self.pending_tag_names = []
  end
end
