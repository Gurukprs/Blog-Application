Rails.application.routes.draw do
  devise_for :users
  root to: 'topics#index'
  resources :topics do
    resources :posts do
      resources :comments, only: [:create, :destroy] do
        resources :user_comment_ratings, only: [:create, :index]
      end
      resources :ratings, only: [:create]
      member do
        post :mark_as_read
      end
    end
  end

  resources :posts, only: [:index]
  resources :tags
end

# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
