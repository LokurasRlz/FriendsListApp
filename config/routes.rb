Rails.application.routes.draw do
  devise_for :users
  get 'home/about'
  root 'tools#index'

  resources :tools do
    member do
      patch 'update_date_of_use'
    end

    collection do
      get 'used_tools'
    end
  end
end
