class RefreshSitrepJob < ApplicationJob
  queue_as :default
  
  def perform(days: 7)
    Rails.logger.info("Starting Sitrep refresh for last #{days} days")
    
    # Fetch GitHub activity
    github_service = GithubActivityService.new
    github_items = github_service.fetch_recent_activity(days: days)
    
    Rails.logger.info("Fetched #{github_items.size} GitHub items")
    
    # Fetch Nostr activity
    nostr_service = NostrFeedService.new
    nostr_items = nostr_service.fetch_recent_posts(days: days)
    
    Rails.logger.info("Fetched #{nostr_items.size} Nostr items")
    
    # Combine and save items
    all_items = github_items + nostr_items
    
    saved_count = 0
    skipped_count = 0
    
    all_items.each do |item_data|
      begin
        item = SitrepItem.find_or_create_from_data(item_data)
        if item.persisted?
          saved_count += 1
        else
          skipped_count += 1
          Rails.logger.debug("Skipped duplicate item: #{item_data[:external_id]}")
        end
      rescue => e
        Rails.logger.error("Error saving sitrep item: #{e.message}")
        Rails.logger.error("Item data: #{item_data.inspect}")
      end
    end
    
    # Clean up old items (older than 30 days)
    deleted_count = SitrepItem.where('published_at < ?', 30.days.ago).delete_all
    
    Rails.logger.info("Sitrep refresh complete: #{saved_count} saved, #{skipped_count} skipped, #{deleted_count} deleted")
    
    {
      saved: saved_count,
      skipped: skipped_count,
      deleted: deleted_count
    }
  end
end
