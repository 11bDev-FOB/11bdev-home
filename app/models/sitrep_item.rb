class SitrepItem < ApplicationRecord
  validates :item_type, presence: true, inclusion: { in: %w[github nostr] }
  validates :title, presence: true
  validates :url, presence: true
  validates :external_id, presence: true, uniqueness: true
  validates :published_at, presence: true
  
  scope :recent, -> { order(published_at: :desc) }
  scope :github_items, -> { where(item_type: 'github') }
  scope :nostr_items, -> { where(item_type: 'nostr') }
  scope :last_week, -> { where('published_at >= ?', 1.week.ago) }
  scope :last_24_hours, -> { where('published_at >= ?', 24.hours.ago) }
  
  def self.find_or_create_from_data(data)
    find_or_create_by(external_id: data[:external_id]) do |item|
      item.item_type = data[:item_type]
      item.title = data[:title]
      item.content = data[:content]
      item.url = data[:url]
      item.published_at = data[:published_at]
      item.metadata = data[:metadata] || {}
    end
  end
end
