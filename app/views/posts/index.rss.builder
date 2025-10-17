xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Tales From the Foxhole - 11b Dev"
    xml.description "News, thoughts, and babble from behind the lines at 11bDEV."
    xml.link "https://11b.dev/blog"
    xml.tag! "atom:link", href: "https://11b.dev/blog.rss", rel: "self", type: "application/rss+xml"
    xml.language "en-us"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.content
        xml.pubDate post.published_at.to_formatted_s(:rfc822) if post.published_at
        xml.link "https://11b.dev/blog/#{post.slug}"
        xml.guid "https://11b.dev/blog/#{post.slug}", isPermaLink: true
        
        # Add author
        xml.author "tim@11b.dev (Tim - 11b Dev)"
        
        # Add tags as categories
        if post.tags.present?
          post.tags.split(',').each do |tag|
            xml.category tag.strip
          end
        end
      end
    end
  end
end
