# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_topic_for_index, only: [:index]
  before_action :set_topic, except: [:index]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # List all posts under particular topic (or all posts when no topic provided)
  def index
    @posts = if @topic
               @topic.posts.order(created_at: :desc)
             else
               Post.includes(:topic).order(created_at: :desc)
             end
  end

  # View a post under particular topic
  def show
    @comment = @post.comments.build
    @comments = @post.comments.order(created_at: :asc)
  end

  # Create post form under particular topic
  def new
    @post = @topic.posts.build
  end

  # Create post under particular topic
  def create
    @post = @topic.posts.build(post_params)

    if @post.save
      redirect_to topic_posts_path(@topic), notice: "Post created successfully."
    else
      render :new
    end
  end

  # Edit post under particular topic
  def edit
    # @post is set via set_post
  end

  # Update post under particular topic
  def update
    if @post.update(post_params)
      redirect_to topic_post_path(@topic, @post), notice: "Post updated successfully."
    else
      render :edit
    end
  end

  # Delete post under particular topic
  def destroy
    @post.destroy
    redirect_to topic_posts_path(@topic), notice: "Post deleted successfully."
  end

  private

  def set_topic_for_index
    @topic = Topic.find_by(id: params[:topic_id]) if params[:topic_id].present?
  end

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def set_post
    @post = @topic.posts.find(params[:id])
  end

  # STRONG PARAMS
  # topic_id can come from nested route OR from query params
  def post_params
    params.require(:post).permit(:title, :body, :topic_id, :tag_names)
  end
end
