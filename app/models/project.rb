class Project < ApplicationRecord
  has_many_attached :images
  has_one_attached :featured_image

  validates :title, presence: true
  validates :description, presence: true
  validates :tech_stack, presence: true

  scope :featured, -> { where(featured: true) }
  scope :published, -> { where(published: true) }

  def to_param
    "#{id}-#{title.parameterize}"
  end

  def featured_image_url
    featured_image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(featured_image, only_path: true) : nil
  end

  def excerpt
    description.to_s.truncate(200)
  end

  def description_html
    description.to_s
  end
end
