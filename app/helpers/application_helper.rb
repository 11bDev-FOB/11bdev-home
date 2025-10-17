module ApplicationHelper
	def markdown(text)
		return "" if text.blank?
		renderer = Kramdown::Document.new(text, input: "GFM", hard_wrap: true)
		html = renderer.to_html
		# Basic sanitize; Rails sanitize is fine for now
		sanitize(html, tags: %w[p br strong em a ul ol li h1 h2 h3 h4 h5 h6 blockquote code pre img], attributes: %w[href src alt title])
	end
end
