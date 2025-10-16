class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: [:edit, :update, :destroy]

  def index
    @posts = Post.order(updated_at: :desc)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to admin_posts_path, notice: "Post saved."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @post.update(post_params)
      redirect_to admin_posts_path, notice: "Post updated."
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: "Post deleted."
  end

  private

  def set_post
    # Admin always resolves by numeric id to avoid slug params in paths
    @post = Post.find_by(id: params[:id]) || Post.find_by!(slug: params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :published, :published_at, :featured_image, :author, :tag_list)
  end
end
