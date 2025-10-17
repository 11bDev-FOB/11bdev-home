class PostsController < ApplicationController
  def index
    @posts = Post.published.order(published_at: :desc)
    
    respond_to do |format|
      format.html
      format.rss { render layout: false }
    end
  end

  def show
    @post = Post.published.find_by!(slug: params[:id])
  end
end
