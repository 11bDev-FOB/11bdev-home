namespace :sitrep do
  desc "Refresh sitrep data from GitHub and Twitter"
  task refresh: :environment do
    puts "Starting Sitrep refresh..."
    result = RefreshSitrepJob.perform_now(days: 7)
    puts "Refresh complete!"
    puts "  Saved: #{result[:saved]}"
    puts "  Skipped: #{result[:skipped]}"
    puts "  Deleted: #{result[:deleted]}"
  end
  
  desc "Test GitHub API connection"
  task test_github: :environment do
    service = GithubActivityService.new
    puts "Testing GitHub API connection..."
    
    if ENV['GITHUB_TOKEN'].present?
      puts "✓ GitHub token found"
      items = service.fetch_recent_activity(days: 7)
      puts "✓ Fetched #{items.size} items from GitHub"
      
      if items.any?
        puts "\nSample items:"
        items.first(3).each do |item|
          puts "  - #{item[:title]}"
        end
      end
    else
      puts "✗ No GitHub token found in environment"
      puts "  Add GITHUB_TOKEN to your .env file"
    end
  end
end
