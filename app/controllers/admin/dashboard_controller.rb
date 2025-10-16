class Admin::DashboardController < Admin::BaseController
  def index
    # Content stats
    @posts_count = Post.count
    @published_posts_count = Post.published.count
    @draft_posts_count = @posts_count - @published_posts_count
    
    @projects_count = Project.count
    @published_projects_count = Project.published.count
    @draft_projects_count = @projects_count - @published_projects_count
    @open_source_projects_count = Project.where(open_source: true).count
    
    # Recent activity
    @recent_posts = Post.order(updated_at: :desc).limit(5)
    @recent_projects = Project.order(updated_at: :desc).limit(5)
    
    # System info
    @ruby_version = RUBY_VERSION
    @rails_version = Rails.version
    @database_size = calculate_database_size
    @uptime = calculate_uptime
  end

  private

  def calculate_database_size
    db_path = Rails.root.join('storage', "#{Rails.env}.sqlite3")
    if File.exist?(db_path)
      size_in_bytes = File.size(db_path)
      "#{(size_in_bytes / 1024.0 / 1024.0).round(2)} MB"
    else
      "N/A"
    end
  end

  def calculate_uptime
    uptime_seconds = Time.current - Rails.application.config.booted_at rescue 0
    hours = (uptime_seconds / 3600).to_i
    minutes = ((uptime_seconds % 3600) / 60).to_i
    "#{hours}h #{minutes}m"
  end
end
