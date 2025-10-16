class Api::PostsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    posts = Post.published.order(created_at: :desc)
    render json: posts.as_json(only: [:id, :title, :author, :slug, :published, :created_at, :updated_at], methods: [:featured_image_url, :excerpt])
  end

  def show
    post = Post.published.find_by(slug: params[:id])
    if post
      render json: post.as_json(only: [:id, :title, :author, :slug, :published, :created_at, :updated_at], methods: [:featured_image_url, :content_html])
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end

  def create
    post = Post.new(post_params)
    if post.save
      render json: post, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    post = Post.find_by(id: params[:id])
    if post&.update(post_params)
      render json: post
    else
      render json: { errors: post&.errors&.full_messages || ["Not found"] }, status: :unprocessable_entity
    end
  end

  def destroy
    post = Post.find_by(id: params[:id])
    if post&.destroy
      render json: { success: true }
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :author, :content, :featured_image, :published)
  end
end
