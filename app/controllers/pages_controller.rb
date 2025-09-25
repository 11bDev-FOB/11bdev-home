class PagesController < ApplicationController
  def home
    @featured_projects = Project.featured.limit(3)
    @testimonials = Testimonial.featured.limit(2)
  end

  def about
    @team_members = [] # Can be expanded later if adding Team model
  end

  def contact
    # Using Letterbird for contact form - no Rails model needed
  end

  def services
    @services = Service.all.by_title
    @testimonials = Testimonial.all
  end
end
