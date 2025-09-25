class Contact < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true

  scope :recent, -> { order(submitted_at: :desc) }

  before_create :set_submitted_at

  private

  def set_submitted_at
    self.submitted_at = Time.current
  end
end
