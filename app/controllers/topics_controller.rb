# app/controllers/topics_controller.rb
class TopicsController < ApplicationController
  before_action :set_topic, only: [:show, :edit, :update, :destroy]

  def index
    @topics = Topic.all.order(:id)
    
    respond_to do |format|
      format.html
      format.json { render json: @topics }
    end
  end

  def show
    @posts = @topic.posts.order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.json { render json: @topic }
    end
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)
    
    respond_to do |format|
      if @topic.save
        format.html { redirect_to topics_path, notice: "Topic created" }
        format.json { render json: @topic, status: :created }
      else
        format.html { render :new }
        format.json { render json: { errors: @topic.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    # Using find ensures a RecordNotFound is raised if id is invalid,
    # which Rails will show as a 404 instead of trying to call update on nil.
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to topic_path(@topic), notice: "Topic updated" }
        format.json { render json: @topic }
      else
        format.html { render :edit }
        format.json { render json: { errors: @topic.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @topic.destroy
    
    respond_to do |format|
      format.html { redirect_to topics_path, notice: "Topic deleted" }
      format.json { head :no_content }
    end
  end

  private

  def set_topic
    # use find (raises if not found) — safer for debugging than find_by returning nil
    @topic = Topic.find(params[:id])
  end

  def topic_params
    # Handle both wrapped (from wrap_parameters) and unwrapped JSON
    if params[:topic].present?
      params.require(:topic).permit(:name)
    else
      # Direct JSON body without wrapping
      params.permit(:name)
    end
  end
end
