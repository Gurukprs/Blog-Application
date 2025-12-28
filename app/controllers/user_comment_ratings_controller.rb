class UserCommentRatingsController < ApplicationController
  before_action :set_topic
  before_action :set_post
  before_action :set_comment

  def create
    @user_comment_rating = @comment.user_comment_ratings.build(user_comment_rating_params)
    @user_comment_rating.user = current_user

    if @user_comment_rating.save
      redirect_to topic_post_path(@topic, @post), notice: "Comment rated successfully."
    else
      redirect_to topic_post_path(@topic, @post), alert: @user_comment_rating.errors.full_messages.join(", ")
    end
  end

  def index
    @user_comment_ratings = @comment.user_comment_ratings.includes(:user).order(created_at: :desc)
  end

  private

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def set_post
    @post = @topic.posts.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:comment_id])
  end

  def user_comment_rating_params
    params.require(:user_comment_rating).permit(:stars)
  end
end





