class Project < ApplicationRecord
  has_many_attached :images
  has_one_attached :featured_image

  validates :title, presence: true
  validates :description, presence: true
  validates :tech_stack, presence: true

  scope :featured, -> { where(featured: true) }
  scope :published, -> { where.not(title: nil) }

  def to_param
    "#{id}-#{title.parameterize}"
  end
end
