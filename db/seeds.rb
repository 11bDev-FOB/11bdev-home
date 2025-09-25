# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
puts "Clearing existing data..."
Project.destroy_all
Testimonial.destroy_all
Service.destroy_all

# Create Projects
puts "Creating projects..."
projects = [
  {
    title: "Hayduke",
    description: "A simple clean Indie blogging service for military grade hipsters.",
    tech_stack: "Rails 7",
    client_outcome: "",
    featured: true
  },
  {
    title: "Yall",
    description: "A social poster and scheduler for Mastodon, Threads, Bluesky, X, and Nostr",
    tech_stack: "Rails 7",
    client_outcome: "",
    featured: true
  },
  {
    title: "Squared Away",
    description: "A super simple and clean Task/Project manager for people who don't need so many bells it sounds like Santas sleigh.",
    tech_stack: "Rails 7",
    client_outcome: "",
    featured: true
  }
]

projects.each do |project_attrs|
  Project.create!(project_attrs)
end

# Create Testimonials
puts "Creating testimonials..."
testimonials = [
  {
    quote: "TaskForce transformed how our team manages complex security operations. The military-inspired workflow just makes sense for our business. We've seen a 40% improvement in project completion rates since switching to their platform.",
    client_name: "Sarah Mitchell",
    company: "Phoenix Security Solutions",
    project: "TaskForce",
    featured: true
  },
  {
    quote: "The VetStack API is incredibly reliable and well-documented. It's allowed us to focus on building our patient care platform instead of dealing with fragmented data sources. Absolutely essential for our operations.",
    client_name: "Dr. James Rodriguez",
    company: "Veterans First Healthcare",
    project: "VetStack API",
    featured: true
  },
  {
    quote: "DeadBase is pure magic! Finally, a place where the community can come together and dive deep into show data. The developers clearly understand the scene - this isn't just software, it's love for the music.",
    client_name: "Tommy 'Sunshine' Walsh",
    company: "Bay Area Deadheads",
    project: "DeadBase",
    featured: true
  },
  {
    quote: "CodeRecon caught vulnerabilities in our codebase that we completely missed. The reporting is developer-friendly and actionable. It's like having a security expert on the team without the overhead cost.",
    client_name: "Mike Chen",
    company: "Startup Collective SF",
    project: "CodeRecon",
    featured: false
  }
]

testimonials.each do |testimonial_attrs|
  Testimonial.create!(testimonial_attrs)
end

puts "Seed data created successfully!"
puts "Created #{Project.count} projects"
puts "Created #{Testimonial.count} testimonials"
