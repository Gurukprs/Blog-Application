require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  let(:user) { create(:user) }
  let!(:tag) { create(:tag) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns all tags' do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:tags)).to include(tag)
    end
  end

  describe 'GET #new' do
    it 'assigns a new tag' do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:tag)).to be_a_new(Tag)
    end
  end

  describe 'GET #edit' do
    it 'loads the requested tag' do
      get :edit, params: { id: tag.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:tag)).to eq(tag)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new tag' do
        expect {
          post :create, params: { tag: { name: 'rails' } }
        }.to change(Tag, :count).by(1)
      end

      it 'redirects back to tags index' do
        post :create, params: { tag: { name: 'rails' } }
        expect(response).to redirect_to(tags_path)
        expect(flash[:notice]).to eq('Tag created successfully.')
      end
    end

    context 'with invalid attributes' do
      it 'does not create a tag' do
        expect {
          post :create, params: { tag: { name: '' } }
        }.not_to change(Tag, :count)
      end

      it 're-renders the new template' do
        post :create, params: { tag: { name: '' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'updates the tag' do
        patch :update, params: { id: tag.id, tag: { name: 'updated' } }
        expect(tag.reload.name).to eq('updated')
      end

      it 'redirects to tags index' do
        patch :update, params: { id: tag.id, tag: { name: 'updated' } }
        expect(response).to redirect_to(tags_path)
        expect(flash[:notice]).to eq('Tag updated successfully.')
      end
    end

    context 'with invalid attributes' do
      it 'does not update the tag' do
        original_name = tag.name
        patch :update, params: { id: tag.id, tag: { name: '' } }
        expect(tag.reload.name).to eq(original_name)
      end

      it 're-renders the edit template' do
        patch :update, params: { id: tag.id, tag: { name: '' } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'removes the tag' do
      expect {
        delete :destroy, params: { id: tag.id }
      }.to change(Tag, :count).by(-1)
    end

    it 'redirects with notice' do
      delete :destroy, params: { id: tag.id }
      expect(response).to redirect_to(tags_path)
      expect(flash[:notice]).to eq('Tag deleted successfully.')
    end
  end
end

