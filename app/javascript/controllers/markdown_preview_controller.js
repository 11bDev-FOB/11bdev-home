import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"
import DOMPurify from "dompurify"

// Stimulus controller for tabbed Markdown editor with preview
export default class extends Controller {
  static targets = ["input", "preview", "writeTab", "previewTab", "writePane", "previewPane"]

  connect() {
    console.log("Markdown preview controller connected!")
    // Configure marked (GitHub-flavored markdown)
    marked.setOptions({
      gfm: true,
      breaks: true
    })
  }

  showWrite(event) {
    event.preventDefault()
    
    // Show write pane, hide preview pane
    this.writePaneTarget.classList.remove("hidden")
    this.previewPaneTarget.classList.add("hidden")
    
    // Update tab styling
    this.writeTabTarget.classList.add("border-olive", "text-dark-olive", "bg-white")
    this.writeTabTarget.classList.remove("border-transparent", "text-gray-500", "hover:text-gray-700")
    
    this.previewTabTarget.classList.remove("border-olive", "text-dark-olive", "bg-white")
    this.previewTabTarget.classList.add("border-transparent", "text-gray-500", "hover:text-gray-700")
  }

  showPreview(event) {
    event.preventDefault()
    
    // Render markdown
    const md = this.inputTarget.value || ""
    const html = marked.parse(md)
    const clean = DOMPurify.sanitize(html)
    this.previewTarget.innerHTML = clean || "<p class='text-gray-400 italic'>Nothing to preview yet...</p>"
    
    // Show preview pane, hide write pane
    this.writePaneTarget.classList.add("hidden")
    this.previewPaneTarget.classList.remove("hidden")
    
    // Update tab styling
    this.previewTabTarget.classList.add("border-olive", "text-dark-olive", "bg-white")
    this.previewTabTarget.classList.remove("border-transparent", "text-gray-500", "hover:text-gray-700")
    
    this.writeTabTarget.classList.remove("border-olive", "text-dark-olive", "bg-white")
    this.writeTabTarget.classList.add("border-transparent", "text-gray-500", "hover:text-gray-700")
  }
}
