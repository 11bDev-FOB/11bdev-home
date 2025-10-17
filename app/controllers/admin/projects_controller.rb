class Admin::ProjectsController < Admin::BaseController
  before_action :set_project, only: [:edit, :update, :destroy]

  def index
    @projects = Project.unscoped.order(position: :asc)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to admin_projects_path, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to admin_projects_path, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to admin_projects_path, notice: "Project deleted."
  end

  def reorder
    params[:order].each_with_index do |id, index|
      Project.where(id: id).update_all(position: index + 1)
    end
    head :ok
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, :tech_stack, :client_outcome, :project_url, :featured_image, :published, :open_source)
  end
end
