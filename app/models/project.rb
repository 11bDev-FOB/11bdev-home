class Project < ApplicationRecord
  has_many_attached :images
  has_one_attached :featured_image

  validates :title, presence: true
  validates :description, presence: true
  validates :tech_stack, presence: true

  scope :featured, -> { where(featured: true) }
  scope :published, -> { where(published: true) }

  default_scope { order(position: :asc) }

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
    return "" if description.blank?
    renderer = Kramdown::Document.new(description.to_s, input: "GFM", hard_wrap: true)
    html = renderer.to_html
    ActionController::Base.helpers.sanitize(html, tags: %w[p br strong em a ul ol li h1 h2 h3 h4 h5 h6 blockquote code pre img], attributes: %w[href src alt title]).html_safe
  end
end
