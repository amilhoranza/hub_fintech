Rails.application.routes.draw do

  resources :accounts do
    member do
      post :deposit
      post :withdraw
      post :transfer
      post :inject_capital
    end
  end

  resources :transactions, only: [:show, :index] do
    member do
      post :reverse
    end
  end

end
