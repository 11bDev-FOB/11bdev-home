class Testimonial < ApplicationRecord
  has_one_attached :client_photo

  validates :quote, presence: true
  validates :client_name, presence: true

  scope :featured, -> { where(featured: true) }

  def display_name
    company.present? ? "#{client_name}, #{company}" : client_name
  end
end
