class Post < ApplicationRecord
  has_one_attached :featured_image
  has_rich_text :content

  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(published_at: :desc) }

  before_validation :generate_slug, if: :title_changed?

  def to_param
    slug
  end

  def published?
    published && published_at&.past?
  end

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end
end
