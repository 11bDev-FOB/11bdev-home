class Api::ProjectsController < Api::BaseController
  # GET /api/projects
  # Returns all published projects
  def index
    projects = Project.published.order(updated_at: :desc)
    render_success(
      projects.as_json(
        only: [:id, :title, :slug, :description, :tech_stack, :project_url, :published, :open_source, :featured, :created_at, :updated_at]
      )
    )
  end

  # GET /api/projects/:id
  # Returns a single project by slug or ID
  def show
    project = Project.published.find_by(slug: params[:id]) || Project.published.find_by(id: params[:id])
    
    if project
      render_success(
        project.as_json(
          only: [:id, :title, :slug, :description, :tech_stack, :project_url, :published, :open_source, :featured, :created_at, :updated_at]
        )
      )
    else
      render_error("Project not found", :not_found)
    end
  end

  # POST /api/projects
  # Creates a new project (requires authentication)
  def create
    project = Project.new(project_params)
    
    if project.save
      render_success(
        project.as_json(
          only: [:id, :title, :slug, :description, :tech_stack, :project_url, :published, :open_source, :featured, :created_at, :updated_at]
        ),
        :created
      )
    else
      render_errors(project.errors.full_messages)
    end
  end

  # PATCH/PUT /api/projects/:id
  # Updates an existing project (requires authentication)
  def update
    project = Project.find_by(id: params[:id]) || Project.find_by(slug: params[:id])
    
    if project.nil?
      render_error("Project not found", :not_found)
    elsif project.update(project_params)
      render_success(
        project.as_json(
          only: [:id, :title, :slug, :description, :tech_stack, :project_url, :published, :open_source, :featured, :created_at, :updated_at]
        )
      )
    else
      render_errors(project.errors.full_messages)
    end
  end

  # DELETE /api/projects/:id
  # Deletes a project (requires authentication)
  def destroy
    project = Project.find_by(id: params[:id]) || Project.find_by(slug: params[:id])
    
    if project.nil?
      render_error("Project not found", :not_found)
    elsif project.destroy
      render_success
    else
      render_errors(project.errors.full_messages)
    end
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :tech_stack, :project_url, :published, :open_source, :featured)
  end
end
