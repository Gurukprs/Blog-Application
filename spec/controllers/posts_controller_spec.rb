require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:topic) { create(:topic) }
  let(:post_record) { create(:post, topic: topic) }
  let(:valid_attributes) { { title: 'New Post', body: 'New Post Body' } }
  let(:invalid_attributes) { { title: '', body: '' } }

  # Helper method to avoid conflict with 'post' variable name
  def post_request(action, params:)
    post action, params: params
  end

  describe 'GET #index' do
    it 'lists all posts under a particular topic' do
      post1 = create(:post, topic: topic)
      post2 = create(:post, topic: topic)
      other_topic = create(:topic)
      other_post = create(:post, topic: other_topic)

      get :index, params: { topic_id: topic.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:posts)).to include(post1, post2)
      expect(assigns(:posts)).not_to include(other_post)
    end

    it 'orders posts by created_at descending' do
      old_post = create(:post, topic: topic, created_at: 2.days.ago)
      new_post = create(:post, topic: topic, created_at: Time.current)

      get :index, params: { topic_id: topic.id }

      expect(assigns(:posts).first).to eq(new_post)
      expect(assigns(:posts).last).to eq(old_post)
    end
  end

  describe 'GET #show' do
    it 'shows a post under a particular topic' do
      get :show, params: { topic_id: topic.id, id: post_record.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:post)).to eq(post_record)
      expect(assigns(:topic)).to eq(topic)
    end

    it 'raises error for post from different topic' do
      other_topic = create(:topic)
      other_post = create(:post, topic: other_topic)

      expect {
        get :show, params: { topic_id: topic.id, id: other_post.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new, params: { topic_id: topic.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:post)).to be_a_new(Post)
      expect(assigns(:post).topic).to eq(topic)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new post under a particular topic' do
        expect {
          post_request :create, params: { topic_id: topic.id, post: valid_attributes }
        }.to change(Post, :count).by(1)

        new_post = Post.last
        expect(new_post.topic).to eq(topic)
        expect(new_post.title).to eq('New Post')
        expect(new_post.body).to eq('New Post Body')
      end

      it 'redirects to the posts index with notice' do
        post_request :create, params: { topic_id: topic.id, post: valid_attributes }

        expect(response).to redirect_to(topic_posts_path(topic))
        expect(flash[:notice]).to eq('Post created successfully.')
      end

      it 'includes topic_id in the request' do
        post_request :create, params: { topic_id: topic.id, post: valid_attributes.merge(topic_id: topic.id) }

        new_post = Post.last
        expect(new_post.topic_id).to eq(topic.id)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new post' do
        expect {
          post_request :create, params: { topic_id: topic.id, post: invalid_attributes }
        }.not_to change(Post, :count)
      end

      it 'renders the new template' do
        post_request :create, params: { topic_id: topic.id, post: invalid_attributes }

        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      get :edit, params: { topic_id: topic.id, id: post_record.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:post)).to eq(post_record)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { title: 'Updated Post', body: 'Updated Body' } }

      it 'updates the requested post' do
        patch :update, params: { topic_id: topic.id, id: post_record.id, post: new_attributes }
        post_record.reload

        expect(post_record.title).to eq('Updated Post')
        expect(post_record.body).to eq('Updated Body')
      end

      it 'redirects to the post show page with notice' do
        patch :update, params: { topic_id: topic.id, id: post_record.id, post: new_attributes }

        expect(response).to redirect_to(topic_post_path(topic, post_record))
        expect(flash[:notice]).to eq('Post updated successfully.')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the post' do
        original_title = post_record.title
        patch :update, params: { topic_id: topic.id, id: post_record.id, post: invalid_attributes }
        post_record.reload

        expect(post_record.title).to eq(original_title)
      end

      it 'renders the edit template' do
        patch :update, params: { topic_id: topic.id, id: post_record.id, post: invalid_attributes }

        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested post' do
      post_to_delete = create(:post, topic: topic)

      expect {
        delete :destroy, params: { topic_id: topic.id, id: post_to_delete.id }
      }.to change(Post, :count).by(-1)
    end

    it 'redirects to the posts index with notice' do
      delete :destroy, params: { topic_id: topic.id, id: post_record.id }

      expect(response).to redirect_to(topic_posts_path(topic))
      expect(flash[:notice]).to eq('Post deleted successfully.')
    end
  end

  describe 'nested routes' do
    it 'uses nested route structure /topics/:topic_id/posts' do
      expect(get: "/topics/#{topic.id}/posts").to route_to(
        controller: 'posts',
        action: 'index',
        topic_id: topic.id.to_s
      )
    end

    it 'requires topic_id in all routes' do
      expect(get: "/topics/#{topic.id}/posts/#{post_record.id}").to route_to(
        controller: 'posts',
        action: 'show',
        topic_id: topic.id.to_s,
        id: post_record.id.to_s
      )
    end
  end
end

