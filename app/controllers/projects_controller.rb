class ProjectsController < ApplicationController
  def index
    @projects = Project.published.order(updated_at: :desc)
  end

  def show
    id = params[:id].to_s.split("-").first
    @project = Project.published.find(id)
  end
end
