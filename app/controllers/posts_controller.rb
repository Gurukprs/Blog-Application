# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_topic_for_index, only: [:index]
  before_action :set_topic, except: [:index]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # List all posts under particular topic (or all posts when no topic provided)
  def index
    scope = Post.all
    scope = scope.where(topic_id: @topic.id) if @topic

    @posts = scope
               .includes(:topic, :tags, :user)
               .order(created_at: :desc)
               .page(params[:page])
               .per(10)
  end

  # View a post under particular topic
  def show
    @comment = @post.comments.build
    @comments = @post.comments.includes(:user).order(created_at: :asc)
    @rating = @post.ratings.build
    @ratings_by_stars = @post.ratings.group(:stars).count
  end

  # Create post form under particular topic
  def new
    @post = @topic.posts.build
    prepare_post_form_data
  end

  # Create post under particular topic
  def create
    @post = @topic.posts.build(post_params)
    @post.user = current_user

    if @post.save
      redirect_to topic_posts_path(@topic), notice: "Post created successfully."
    else
      prepare_post_form_data
      render :new
    end
  end

  # Edit post under particular topic
  def edit
    authorize! :update, @post
    # @post is set via set_post
    prepare_post_form_data
  end

  # Update post under particular topic
  def update
    authorize! :update, @post
    if @post.update(post_params)
      redirect_to topic_post_path(@topic, @post), notice: "Post updated successfully."
    else
      prepare_post_form_data
      render :edit
    end
  end

  # Delete post under particular topic
  def destroy
    authorize! :destroy, @post
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
    @post = @topic.posts.includes(:tags, :user).find(params[:id])
  end

  # STRONG PARAMS
  # topic_id can come from nested route OR from query params
  def post_params
    params.require(:post).permit(:title, :body, :topic_id, :image, tag_ids: [], tags_attributes: [:name])
  end

  def prepare_post_form_data
    @available_tags = Tag.order(:name)
  end
end
