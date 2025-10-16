class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_request, only: [:create, :update, :destroy]

  private

  def authenticate_api_request
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV.fetch("ADMIN_USERNAME", "admin") && 
      password == ENV.fetch("ADMIN_PASSWORD", "changeme")
    end
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_errors(errors, status = :unprocessable_entity)
    render json: { errors: errors }, status: status
  end

  def render_success(data = nil, status = :ok)
    if data
      render json: data, status: status
    else
      render json: { success: true }, status: status
    end
  end
end
