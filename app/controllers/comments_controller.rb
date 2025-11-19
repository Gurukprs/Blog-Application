class CommentsController < ApplicationController
  before_action :set_topic
  before_action :set_post
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @post.comments.build(comment_params)

    if @comment.save
      redirect_to topic_post_path(@topic, @post), notice: "Comment added successfully."
    else
      @comments = @post.comments.order(created_at: :asc)
      render "posts/show", status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    redirect_to topic_post_path(@topic, @post), notice: "Comment deleted."
  end

  private

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def set_post
    @post = @topic.posts.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
