# app/controllers/topics_controller.rb
class TopicsController < ApplicationController
  before_action :set_topic, only: [:show, :edit, :update, :destroy]

  def index
    @topics = Topic.all.order(:id)
  end

  def show
    @posts = @topic.posts.order(created_at: :desc)
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)
    if @topic.save
      redirect_to topics_path, notice: "Topic created"
    else
      render :new
    end
  end

  def edit
  end

  def update
    # Using find ensures a RecordNotFound is raised if id is invalid,
    # which Rails will show as a 404 instead of trying to call update on nil.
    if @topic.update(topic_params)
      redirect_to topic_path(@topic), notice: "Topic updated"
    else
      render :edit
    end
  end

  def destroy
    @topic.destroy
    redirect_to topics_path, notice: "Topic deleted"
  end

  private

  def set_topic
    # use find (raises if not found) — safer for debugging than find_by returning nil
    @topic = Topic.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:name)
  end
end
