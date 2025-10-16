class Api::ProjectsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    projects = Project.published.order(created_at: :desc)
    render json: projects.as_json(only: [:id, :name, :slug, :published, :open_source, :created_at, :updated_at], methods: [:featured_image_url, :excerpt])
  end

  def show
    project = Project.published.find_by(slug: params[:id])
    if project
      render json: project.as_json(only: [:id, :name, :slug, :published, :open_source, :created_at, :updated_at], methods: [:featured_image_url, :description_html])
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end

  def create
    project = Project.new(project_params)
    if project.save
      render json: project, status: :created
    else
      render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    project = Project.find_by(id: params[:id])
    if project&.update(project_params)
      render json: project
    else
      render json: { errors: project&.errors&.full_messages || ["Not found"] }, status: :unprocessable_entity
    end
  end

  def destroy
    project = Project.find_by(id: params[:id])
    if project&.destroy
      render json: { success: true }
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, :featured_image, :published, :open_source)
  end
end
