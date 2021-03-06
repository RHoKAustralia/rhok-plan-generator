RhokPlanGenerator::Application.routes.draw do

  root :to => "home#index"

  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  get "api/events/:event_id/trigger", to: "events#trigger", as: 'trigger_event'

  resources :home, only: [:index]
  get "home/visualisation", to: "home#visualisation", as: 'home_visualisation'

  resources :tasks, only: [:create]
  delete "tasks/:guid",        to: "tasks#destroy"
  post   "tasks/:guid/update", to: "tasks#update" # explicit to allow update using post

  resources :plans, only: [:create]
  get  "plans/:public_guid/show", to: "plans#show", as: 'plan'
  post "plans/:public_guid/duplicate", to: "plans#duplicate", as: 'plan_duplicate'

  get  "plans/private/:private_guid/download", to: "plans#download", as: 'plan_download'
  get  "plans/private/:private_guid/edit", to: "plans#edit", as: 'plan_edit'
  post "plans/private/:private_guid/update", to: "plans#update", as: 'plan_update'

  resources :signups, only: [:new, :create]
  get '/signups', to: redirect('/signups/new')

  resources :people
end
