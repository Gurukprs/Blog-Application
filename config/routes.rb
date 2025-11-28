Rails.application.routes.draw do
  resources :topics do
    resources :posts do
      resources :comments, only: [:create, :destroy]
      resources :ratings, only: [:create]
    end
  end

  resources :posts, only: [:index]
  resources :tags
end

# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
