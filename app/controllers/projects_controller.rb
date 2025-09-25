class ProjectsController < ApplicationController
  def index
    @projects = Project.published
  end
end
