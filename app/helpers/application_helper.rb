module ApplicationHelper
	def markdown(text)
		return "" if text.blank?
		renderer = Kramdown::Document.new(
			text, 
			input: "GFM",
			hard_wrap: false,  # Don't convert single line breaks to <br>
			auto_ids: true,    # Generate IDs for headers
			syntax_highlighter: nil,
			smart_quotes: ["apos", "apos", "quot", "quot"]
		)
		html = renderer.to_html
		# Comprehensive sanitize with all needed tags and attributes
		sanitize(html, 
			tags: %w[p br strong em a ul ol li h1 h2 h3 h4 h5 h6 blockquote code pre img hr table thead tbody tr th td div span],
			attributes: %w[href src alt title class id target rel]
		)
	end
end
