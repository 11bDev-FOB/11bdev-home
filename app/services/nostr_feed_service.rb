class NostrFeedService
  require 'faye/websocket'
  require 'eventmachine'
  require 'json'
  
  # Your Nostr public key
  NPUB = 'npub13hyx3qsqk3r7ctjqrr49uskut4yqjsxt8uvu4rekr55p08wyhf0qq90nt7'
  HASHTAG = '#11bdev'
  
  # Nostr relays to use
  RELAYS = [
    'wss://relay.damus.io',
    'wss://relay.primal.net',
    'wss://premium.primal.net'
  ]
  
  def initialize
    # Convert npub to hex pubkey
    @hex_pubkey = npub_to_hex(NPUB)
    @events = []
    @connections = 0
  end
  
  def fetch_recent_posts(days: 7)
    return [] unless @hex_pubkey
    
    since_timestamp = days.days.ago.to_i
    
    # Run EventMachine to fetch from relays
    EM.run do
      # Set timeout
      EM.add_timer(10) do
        Rails.logger.debug("Nostr fetch timeout after 10 seconds")
        EM.stop
      end
      
      # Connect to each relay
      RELAYS.each do |relay_url|
        fetch_from_relay(relay_url, since_timestamp)
      end
    end
    
    # Filter for hashtag and format
    filtered_events = @events.select do |event|
      event['content'] && event['content'].downcase.include?(HASHTAG.downcase)
    end
    
    Rails.logger.info("Found #{filtered_events.size} Nostr notes with #{HASHTAG}")
    
    filtered_events.map do |event|
      format_nostr_note(event)
    end
  rescue => e
    Rails.logger.error("Error fetching Nostr posts: #{e.message}")
    []
  end
  
  private
  
  def npub_to_hex(npub)
    require 'bech32'
    
    hrp, data = Bech32.decode(npub)
    return nil unless hrp == 'npub' && data
    
    bytes = Bech32.convert_bits(data, 5, 8, false)
    bytes.pack('C*').unpack1('H*')
  rescue => e
    Rails.logger.error("Error converting npub to hex: #{e.message}")
    nil
  end
  
  def fetch_from_relay(relay_url, since_timestamp)
    ws = Faye::WebSocket::Client.new(relay_url)
    
    ws.on :open do |event|
      Rails.logger.debug("Connected to #{relay_url}")
      @connections += 1
      
      # Send REQ message to request events
      # Nostr filter: kind 1 (text notes), author is our pubkey, since timestamp
      subscription_id = SecureRandom.hex(8)
      req_message = [
        "REQ",
        subscription_id,
        {
          "authors" => [@hex_pubkey],
          "kinds" => [1],  # Text notes
          "since" => since_timestamp,
          "limit" => 50
        }
      ].to_json
      
      ws.send(req_message)
      Rails.logger.debug("Sent REQ to #{relay_url}")
      
      # Close connection after 8 seconds
      EM.add_timer(8) do
        close_message = ["CLOSE", subscription_id].to_json
        ws.send(close_message)
        ws.close
      end
    end
    
    ws.on :message do |event|
      begin
        data = JSON.parse(event.data)
        
        # Nostr relay messages: ["EVENT", subscription_id, event_object]
        if data[0] == "EVENT" && data[2]
          nostr_event = data[2]
          @events << nostr_event unless @events.any? { |e| e['id'] == nostr_event['id'] }
          Rails.logger.debug("Received event from #{relay_url}")
        elsif data[0] == "EOSE"
          # End of stored events
          Rails.logger.debug("EOSE from #{relay_url}")
        end
      rescue JSON::ParserError => e
        Rails.logger.debug("Error parsing message from #{relay_url}: #{e.message}")
      end
    end
    
    ws.on :close do |event|
      Rails.logger.debug("Disconnected from #{relay_url}")
      @connections -= 1
      
      # Stop EM if all connections are closed
      EM.stop if @connections <= 0
    end
    
    ws.on :error do |event|
      Rails.logger.debug("Error with #{relay_url}: #{event.message}")
      @connections -= 1
      EM.stop if @connections <= 0
    end
  end
  
  def format_nostr_note(event)
    content = event['content'] || ''
    event_id = event['id']
    created_at = event['created_at']
    
    {
      item_type: 'nostr',
      external_id: "nostr-#{event_id}",
      title: "⚡ Note from Nostr",
      content: content.truncate(300),
      url: "https://njump.me/#{event_id}",
      published_at: Time.at(created_at.to_i),
      metadata: {
        event_id: event_id,
        platform: 'nostr',
        npub: NPUB
      }
    }
  end
end
