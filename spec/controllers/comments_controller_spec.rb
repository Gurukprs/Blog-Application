require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:topic) { create(:topic) }
  let(:post_record) { create(:post, topic: topic) }

  before do
    sign_in user
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a comment for the post and redirects back to post' do
        expect {
          post :create, params: { topic_id: topic.id, post_id: post_record.id, comment: { body: 'Great post!' } }
        }.to change(Comment, :count).by(1)

        expect(response).to redirect_to(topic_post_path(topic, post_record))
        expect(flash[:notice]).to eq('Comment added successfully.')
      end
    end

    context 'with invalid params' do
      it 'does not create a comment and renders posts/show' do
        expect {
          post :create, params: { topic_id: topic.id, post_id: post_record.id, comment: { body: '' } }
        }.not_to change(Comment, :count)

        expect(response).to render_template('posts/show')
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'removes the comment and redirects back' do
      comment = create(:comment, post: post_record)

      expect {
        delete :destroy, params: { topic_id: topic.id, post_id: post_record.id, id: comment.id }
      }.to change(Comment, :count).by(-1)

      expect(response).to redirect_to(topic_post_path(topic, post_record))
      expect(flash[:notice]).to eq('Comment deleted.')
    end
  end
end


