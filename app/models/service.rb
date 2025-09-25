class Service < ApplicationRecord
  has_one_attached :service_image

  validates :title, presence: true
  validates :description, presence: true

  scope :featured, -> { where(featured: true) }
  scope :by_title, -> { order(:title) }
end
