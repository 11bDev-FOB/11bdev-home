class GithubActivityService
  include HTTParty
  base_uri 'https://api.github.com'
  
  ORG_NAME = '11bDev-FOB'
  
  def initialize(token: nil)
    @token = token || ENV['GITHUB_TOKEN']
    @headers = {
      'Accept' => 'application/vnd.github+json',
      'X-GitHub-Api-Version' => '2022-11-28'
    }
    @headers['Authorization'] = "Bearer #{@token}" if @token
  end
  
  def fetch_recent_activity(days: 7)
    items = []
    
    # Fetch recent events from the organization
    events = fetch_org_events(days)
    items.concat(process_events(events))
    
    # Fetch recent repositories and their commits
    repos = fetch_active_repos(days)
    items.concat(process_repos(repos))
    
    items
  end
  
  private
  
  def fetch_org_events(days)
    since_date = days.days.ago.iso8601
    response = self.class.get(
      "/orgs/#{ORG_NAME}/events",
      headers: @headers,
      query: { per_page: 50 }
    )
    
    return [] unless response.success?
    
    events = response.parsed_response
    events.select { |e| Time.parse(e['created_at']) >= days.days.ago }
  rescue => e
    Rails.logger.error("Error fetching GitHub org events: #{e.message}")
    []
  end
  
  def fetch_active_repos(days)
    response = self.class.get(
      "/orgs/#{ORG_NAME}/repos",
      headers: @headers,
      query: { per_page: 30, sort: 'pushed', direction: 'desc' }
    )
    
    return [] unless response.success?
    
    repos = response.parsed_response
    repos.select { |r| Time.parse(r['pushed_at']) >= days.days.ago }
  rescue => e
    Rails.logger.error("Error fetching GitHub repos: #{e.message}")
    []
  end
  
  def process_events(events)
    items = []
    
    # Group events by repository and type
    event_groups = events.group_by { |e| [e['repo']['name'], e['type']] }
    
    event_groups.each do |(repo_name, event_type), group_events|
      next if group_events.empty?
      
      latest_event = group_events.first
      
      case event_type
      when 'PushEvent'
        commits_count = group_events.sum { |e| e.dig('payload', 'commits')&.size || 0 }
        items << format_push_event(latest_event, commits_count)
      when 'PullRequestEvent'
        items << format_pull_request_event(latest_event)
      when 'IssuesEvent'
        items << format_issue_event(latest_event)
      when 'CreateEvent'
        items << format_create_event(latest_event)
      end
    end
    
    items.compact
  end
  
  def process_repos(repos)
    repos.map do |repo|
      {
        item_type: 'github',
        external_id: "github-repo-#{repo['id']}-#{repo['pushed_at']}",
        title: "📂 #{repo['name']} updated",
        content: repo['description'] || 'Repository activity',
        url: repo['html_url'],
        published_at: Time.parse(repo['pushed_at']),
        metadata: {
          repo_name: repo['name'],
          language: repo['language'],
          stars: repo['stargazers_count'],
          event_type: 'repository_update'
        }
      }
    end
  rescue => e
    Rails.logger.error("Error processing repos: #{e.message}")
    []
  end
  
  def format_push_event(event, commits_count)
    repo_name = event['repo']['name'].split('/').last
    {
      item_type: 'github',
      external_id: "github-push-#{event['id']}",
      title: "🚀 #{commits_count} commit#{'s' if commits_count != 1} to #{repo_name}",
      content: event.dig('payload', 'commits')&.first&.dig('message') || 'Code changes pushed',
      url: "https://github.com/#{event['repo']['name']}",
      published_at: Time.parse(event['created_at']),
      metadata: {
        repo_name: repo_name,
        commits_count: commits_count,
        event_type: 'push'
      }
    }
  end
  
  def format_pull_request_event(event)
    pr = event['payload']['pull_request']
    repo_name = event['repo']['name'].split('/').last
    action = event['payload']['action']
    
    {
      item_type: 'github',
      external_id: "github-pr-#{pr['id']}-#{action}",
      title: "🔀 PR #{action} in #{repo_name}: #{pr['title']}",
      content: pr['body']&.truncate(200) || 'Pull request activity',
      url: pr['html_url'],
      published_at: Time.parse(event['created_at']),
      metadata: {
        repo_name: repo_name,
        pr_number: pr['number'],
        event_type: 'pull_request',
        action: action
      }
    }
  end
  
  def format_issue_event(event)
    issue = event['payload']['issue']
    repo_name = event['repo']['name'].split('/').last
    action = event['payload']['action']
    
    {
      item_type: 'github',
      external_id: "github-issue-#{issue['id']}-#{action}",
      title: "🐛 Issue #{action} in #{repo_name}: #{issue['title']}",
      content: issue['body']&.truncate(200) || 'Issue activity',
      url: issue['html_url'],
      published_at: Time.parse(event['created_at']),
      metadata: {
        repo_name: repo_name,
        issue_number: issue['number'],
        event_type: 'issue',
        action: action
      }
    }
  end
  
  def format_create_event(event)
    repo_name = event['repo']['name'].split('/').last
    ref_type = event.dig('payload', 'ref_type')
    
    {
      item_type: 'github',
      external_id: "github-create-#{event['id']}",
      title: "✨ New #{ref_type} created in #{repo_name}",
      content: "A new #{ref_type} was created",
      url: "https://github.com/#{event['repo']['name']}",
      published_at: Time.parse(event['created_at']),
      metadata: {
        repo_name: repo_name,
        ref_type: ref_type,
        event_type: 'create'
      }
    }
  end
end
