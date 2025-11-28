require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:user) { create(:user) }
  let(:topic) { create(:topic) }
  let(:post_record) { create(:post, topic: topic) }
  let(:valid_attributes) { { title: 'New Post', body: 'New Post Body' } }
  let(:invalid_attributes) { { title: '', body: '' } }

  before do
    sign_in user
  end

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

    it 'lists all posts when no topic is specified' do
      topic_one = create(:topic, name: 'One')
      topic_two = create(:topic, name: 'Two')
      post_in_one = create(:post, topic: topic_one)
      post_in_two = create(:post, topic: topic_two)

      get :index

      expect(response).to have_http_status(:success)
      expect(assigns(:posts)).to include(post_in_one, post_in_two)
    end

    it 'paginates topic posts with 10 items per page' do
      create_list(:post, 12, topic: topic)

      get :index, params: { topic_id: topic.id }

      expect(assigns(:posts).size).to eq(10)
      expect(assigns(:posts).current_page).to eq(1)
      expect(assigns(:posts).limit_value).to eq(10)
      expect(assigns(:posts).first.association(:topic)).to be_loaded
    end

    it 'returns remaining posts on the next page' do
      create_list(:post, 15)

      get :index, params: { page: 2 }

      expect(assigns(:posts).current_page).to eq(2)
      expect(assigns(:posts).size).to eq(5)
      expect(assigns(:posts).limit_value).to eq(10)
    end
  end

  describe 'GET #show' do
    let!(:existing_comment) { create(:comment, post: post_record) }

    it 'shows a post under a particular topic' do
      get :show, params: { topic_id: topic.id, id: post_record.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:post)).to eq(post_record)
      expect(assigns(:topic)).to eq(topic)
      expect(assigns(:comment)).to be_a_new(Comment)
      expect(assigns(:comments)).to include(existing_comment)
      expect(assigns(:rating)).to be_a_new(Rating)
      expect(assigns(:ratings_by_stars)).to be_a(Hash)
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
    let!(:existing_tag) { create(:tag, name: 'rails') }

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

      it 'associates existing tags when tag_ids are provided' do
        post_request :create,
                      params: {
                        topic_id: topic.id,
                        post: valid_attributes.merge(tag_ids: [existing_tag.id])
                      }

        new_post = Post.last
        expect(new_post.tags).to include(existing_tag)
      end

      it 'creates new tags from nested attributes' do
        expect {
          post_request :create,
                        params: {
                          topic_id: topic.id,
                          post: valid_attributes.merge(
                            tags_attributes: {
                              "0" => { name: 'Ruby' },
                              "1" => { name: '' }
                            }
                          )
                        }
        }.to change(Tag, :count).by(1)

        new_post = Post.last
        expect(new_post.tags.pluck(:name)).to include('ruby')
      end

      it 'attaches an image when image is provided' do
        image_path = Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')
        image_file = fixture_file_upload(image_path, 'image/png')
        
        post_request :create,
                      params: {
                        topic_id: topic.id,
                        post: valid_attributes.merge(image: image_file)
                      }

        new_post = Post.last
        expect(new_post.image).to be_attached
        expect(new_post.image.content_type).to eq('image/png')
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

      it 'updates the post image when a new image is provided' do
        # Attach initial image
        image_path = Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')
        initial_image = fixture_file_upload(image_path, 'image/png')
        post_record.image.attach(initial_image)
        initial_blob_id = post_record.image.blob.id

        # Update with new image
        new_image = fixture_file_upload(image_path, 'image/png')
        patch :update, params: { topic_id: topic.id, id: post_record.id, post: { image: new_image } }
        post_record.reload

        expect(post_record.image).to be_attached
        expect(post_record.image.blob.id).not_to eq(initial_blob_id)
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

  describe 'authentication' do
    it 'requires authentication to access posts' do
      sign_out user
      get :index, params: { topic_id: topic.id }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'allows authenticated users to access posts' do
      get :index, params: { topic_id: topic.id }
      expect(response).to have_http_status(:success)
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

    it 'supports a global /posts route for listing all posts' do
      expect(get: "/posts").to route_to(
        controller: 'posts',
        action: 'index'
      )
    end
  end
end

