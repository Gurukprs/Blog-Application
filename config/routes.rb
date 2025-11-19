Rails.application.routes.draw do
  resources :topics do
    resources :posts do
      resources :comments, only: [:create, :destroy]
    end
  end

  resources :posts, only: [:index]
end

# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
