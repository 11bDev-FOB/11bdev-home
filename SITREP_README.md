# Sitrep Feature Documentation

## Overview
The Sitrep (Situation Report) page is an activity feed that aggregates and displays activity from:
- GitHub organization (11bDev-FOB) - both public and private repos
- X/Twitter feed (@11bdev with #11bdev hashtag)

## Features
✅ Fetches GitHub events (commits, PRs, issues, new repos)
✅ Caches data in the database to avoid constant API calls
✅ Beautiful, responsive UI with Tailwind CSS
✅ Activity grouped by date
✅ Metadata display (repo names, commit counts, stars, etc.)
✅ Manual refresh button
✅ Supports both public and private repos with GitHub token
✅ Automatic cleanup of old items (30+ days)

## Access
- **URL**: `/sitrep`
- **Navigation**: Added to main navigation menu

## Configuration

### GitHub Token (Required for Private Repos)
Your GitHub token is stored in `.env`:
```bash
GITHUB_TOKEN=your_github_token_here
```

**Token Permissions Required:**
- `repo` - Full control of private repositories
- `read:org` - Read org and team membership

### Twitter/X API (Optional)
To enable X feed integration, add to `.env`:
```bash
TWITTER_BEARER_TOKEN=your_token_here
```

## Usage

### Manual Refresh
Click the "🔄 Refresh Feed" button on the Sitrep page, or use:
```bash
bin/rails runner "RefreshSitrepJob.perform_now(days: 7)"
```

### Rake Tasks
```bash
# Refresh sitrep data
rake sitrep:refresh

# Test GitHub API connection
rake sitrep:test_github
```

### Automated Refresh
For production, set up a cron job or use a scheduler like `whenever` gem:
```bash
# Refresh every hour
0 * * * * cd /path/to/app && bin/rails runner "RefreshSitrepJob.perform_now(days: 7)"
```

Or add to your deployment with Solid Queue recurring jobs.

## Database Schema
```ruby
create_table :sitrep_items do |t|
  t.string :item_type      # 'github' or 'twitter'
  t.string :title          # Display title
  t.text :content          # Content/description
  t.string :url            # Link to original item
  t.string :external_id    # Unique ID (prevents duplicates)
  t.datetime :published_at # When the activity occurred
  t.json :metadata         # Additional data (repo name, stars, etc.)
  t.timestamps
end
```

## Architecture

### Services
- `GithubActivityService` - Fetches GitHub org activity
- `TwitterFeedService` - Fetches X posts (when configured)

### Jobs
- `RefreshSitrepJob` - Background job that fetches and caches data

### Models
- `SitrepItem` - Stores cached activity items

### Controllers
- `SitrepController` - Displays the feed and handles refresh requests

## Docker Deployment
The app is already configured for Docker deployment per your rules. When deploying:

1. Make sure to set environment variables in your deployment:
   ```bash
   docker-compose up -d
   # Or with docker run:
   docker run -e GITHUB_TOKEN=your_token ...
   ```

2. For production, consider using Docker secrets or environment files

## What Data is Fetched?

### From GitHub (Both Public & Private):
- Push events (commits)
- Pull requests (opened, merged, closed)
- Issues (opened, closed)
- New branches/tags
- Repository updates

### From X/Twitter (when configured):
- Posts from @11bdev containing #11bdev
- Engagement metrics (likes, retweets)

## Privacy & Security
- ✅ `.env` file is in `.gitignore`
- ✅ Token has restricted file permissions (600)
- ✅ API calls are cached to minimize exposure
- ✅ Old data is automatically cleaned up after 30 days

## Troubleshooting

### No GitHub data showing?
```bash
# Test the connection
rake sitrep:test_github

# Check token is set
bin/rails runner "puts ENV['GITHUB_TOKEN'].present? ? 'Token found' : 'No token'"
```

### Rate limits?
GitHub API rate limits:
- Without auth: 60 requests/hour
- With auth: 5,000 requests/hour

The app caches data to minimize API calls.

## Future Enhancements
- [ ] Auto-refresh every hour via Solid Queue
- [ ] RSS feed export
- [ ] Filter by repo or activity type
- [ ] Discord webhook integration
- [ ] Email digest option
