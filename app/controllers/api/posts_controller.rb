class Api::PostsController < Api::BaseController
  # GET /api/posts
  # Returns all published posts
  def index
    posts = Post.published.order(published_at: :desc)
    render_success(
      posts.as_json(
        only: [:id, :title, :author, :slug, :published, :published_at, :created_at, :updated_at],
        methods: [:tag_list]
      )
    )
  end

  # GET /api/posts/:id
  # Returns a single post by slug or ID
  def show
    post = Post.published.find_by(slug: params[:id]) || Post.published.find_by(id: params[:id])
    
    if post
      render_success(
        post.as_json(
          only: [:id, :title, :author, :slug, :content, :published, :published_at, :created_at, :updated_at],
          methods: [:tag_list]
        )
      )
    else
      render_error("Post not found", :not_found)
    end
  end

  # POST /api/posts
  # Creates a new post (requires authentication)
  def create
    post = Post.new(post_params)
    
    if post.save
      render_success(
        post.as_json(
          only: [:id, :title, :author, :slug, :content, :published, :published_at, :created_at, :updated_at],
          methods: [:tag_list]
        ),
        :created
      )
    else
      render_errors(post.errors.full_messages)
    end
  end

  # PATCH/PUT /api/posts/:id
  # Updates an existing post (requires authentication)
  def update
    post = Post.find_by(id: params[:id]) || Post.find_by(slug: params[:id])
    
    if post.nil?
      render_error("Post not found", :not_found)
    elsif post.update(post_params)
      render_success(
        post.as_json(
          only: [:id, :title, :author, :slug, :content, :published, :published_at, :created_at, :updated_at],
          methods: [:tag_list]
        )
      )
    else
      render_errors(post.errors.full_messages)
    end
  end

  # DELETE /api/posts/:id
  # Deletes a post (requires authentication)
  def destroy
    post = Post.find_by(id: params[:id]) || Post.find_by(slug: params[:id])
    
    if post.nil?
      render_error("Post not found", :not_found)
    elsif post.destroy
      render_success
    else
      render_errors(post.errors.full_messages)
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :author, :content, :published, :published_at, :tag_list)
  end
end
