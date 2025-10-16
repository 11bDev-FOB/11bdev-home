class Post < ApplicationRecord
  has_one_attached :featured_image

  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :published, -> { where(published: true).where("published_at IS NULL OR published_at <= ?", Time.current) }
  scope :recent, -> { order(published_at: :desc) }

  before_validation :generate_slug, if: :title_changed?
  before_validation :set_default_author
  before_save :serialize_tags

  # Tag handling
  def tag_list
    tags.to_s.split(',').map(&:strip).reject(&:blank?)
  end

  def tag_list=(value)
    @tag_list_cache = value
  end

  def to_param
    slug
  end

  def published?
    return false unless published
    published_at.present? ? published_at <= Time.current : true
  end

  before_save :set_published_at

  def set_published_at
    if will_save_change_to_published? && published && published_at.blank?
      self.published_at = Time.current
    end
  end

  def featured_image_url
    featured_image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(featured_image, only_path: true) : nil
  end

  def excerpt
    content.to_s.truncate(200)
  end

  def content_html
    # Server-side HTML from Markdown for API consumers
    ApplicationController.helpers.markdown(content)
  end

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end

  def set_default_author
    self.author = "Tim" if author.blank?
  end

  def serialize_tags
    if @tag_list_cache
      self.tags = @tag_list_cache.split(',').map(&:strip).reject(&:blank?).join(',')
    end
  end
end
