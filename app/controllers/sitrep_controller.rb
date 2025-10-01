class SitrepController < ApplicationController
  def index
    @sitrep_items = SitrepItem.recent.limit(50)
    
    # Group items by date for better display
    @items_by_date = @sitrep_items.group_by { |item| item.published_at.to_date }
    
    # Stats for the header
    @stats = {
      total_items: @sitrep_items.count,
      github_count: @sitrep_items.github_items.count,
      nostr_count: @sitrep_items.nostr_items.count,
      last_24h: SitrepItem.last_24_hours.count
    }
  end
  
  def refresh
    # Trigger the background job
    RefreshSitrepJob.perform_later(days: 7)
    
    redirect_to sitrep_path, notice: "Sitrep refresh started. Check back in a moment."
  end
end
