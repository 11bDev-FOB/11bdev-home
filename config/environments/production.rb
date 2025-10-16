# Load the Rails application.
require_relative "../application"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory usage.
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  # Enable serving of static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.variant_processor = :mini_magick
  
  # Store files on local file system for production
  config.active_storage.service = :local

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = false

  # Log to STDOUT if in Docker or Heroku, otherwise use default logging.
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Do not log passwords, credit card numbers, etc.
  config.filter_parameters += %i[ passw email secret token _key crypt salt certificate otp ssn ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Email configuration (not required when using Letterbird-only contact)
  # Enable delivery errors to be shown
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # Set host to be used by links generated in mailer templates
  config.action_mailer.default_url_options = { 
    host: "11b.dev", 
    protocol: "https" 
  }

  # Email delivery method - using environment variables for flexibility
  # You can set these via Docker environment variables or Rails credentials
  if ENV['SMTP_ADDRESS'].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV['SMTP_ADDRESS'],
      port:                 ENV['SMTP_PORT']&.to_i || 587,
      domain:               ENV['SMTP_DOMAIN'] || '11b.dev',
      user_name:            ENV['SMTP_USERNAME'],
      password:             ENV['SMTP_PASSWORD'],
      authentication:       ENV['SMTP_AUTH']&.to_sym || :plain,
      enable_starttls_auto: true
    }
  end

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [
    "11b.dev",           # Allow requests from 11b.dev
    "www.11b.dev",
    "app",               # Allow requests from Docker service name
    "rails_app"          # Allow requests from nginx upstream name        # Allow requests from www.11b.dev if needed
  ]

end
