StartupWeekend::Application.routes.draw do
  resources :submissions

  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users

  resources :users do
    resources :submissions
  end
end
