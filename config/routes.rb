Rails.application.routes.draw do

  get 'static_pages/help'
  get 'static_pages/home'

  get 'signup'  => 'users#new'
  get 'sessions/new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  
  root :to => 'static_pages#home'
  
  # TODO: clean up this path
  #get 'update_offices', to: 'users#update_offices', as: 'update_offices'
  #get 'users/batch_new', to: 'users#batch_new', as: :users_batch_new
  #post 'users/batch_create', to: 'users#batch_create', as: :users_batch_create
  #get 'users/batch_add_user', to: 'users#batch_add_user', as: :users_batch_add_user
  resources :users do
    collection do
      get 'update_offices'
      get 'batch_new'
      post 'batch_create'
      get 'batch_add_user'
    end
    member do 
      delete 'destroy_image'
      patch 'upload_image'
      get 'coworkers'
      get 'subordinates'
      post 'admin_approve'
      post 'admin_unapprove'
      post 'admin_kick'
    end
  end
  #delete 'users/:id/destroy_image', to: 'users#destroy_image', as: :user_destroy_image
  #patch 'users/:id/upload_image', to: 'users#upload_image', as: :user_upload_image
  
  resources :account_activations, only: [:edit]
  resources :account_approvals,   only: [:edit]
  resources :added_by_admins,     only: [:edit, :update]
  resources :password_resets,     only: [:new, :create, :edit, :update]
 
  resources :companies do
    member do
      get 'managers'
      get 'employees'
    end

    resources :offices do
      member do
        get 'managers'
        get 'agents'
      end
    end
  end

  resources :buildings do
    get :autocomplete_building_formatted_street_address, :on => :collection
    member do
      get 'delete_modal'
      get 'inaccuracy_modal'
      patch 'send_inaccuracy'
    end
  end
  
  resources :residential_units do
    member do
      get 'delete_modal'
      get 'duplicate_modal'
      post 'duplicate'
      get 'inaccuracy_modal'
      patch 'send_inaccuracy'
      get 'take_off_modal'
      patch 'take_off'
      get 'print_modal'
      get 'print_public'
      get 'print_private'
    end
    collection do
      get 'print_list'
      get 'neighborhoods_modal'
      get 'features_modal'
    end
  end

  resources :landlords do
    member do
      get 'delete_modal'
    end
  end

  resources :neighborhoods

  get 'search/landlords', to: 'landlords#filter', as: :landlords_filter
  get 'search/residential_units', to: 'residential_units#filter', as: :residential_units_filter
  get 'search/buildings', to: 'buildings#filter', as: :buildings_filter

  resources :building_amenities

  resources :commercial_units do
    member do
      get 'delete_modal'
      get 'duplicate_modal'
      post 'duplicate'
      get 'inaccuracy_modal'
      patch 'send_inaccuracy'
    #   get 'take_off_modal'
    #   patch 'take_off'
      get 'print_modal'
      get 'print_public'
    #  get 'print_private'
    end
    collection do
      get 'print_list'
      get 'update_subtype'
      # get 'neighborhoods_modal'
      # get 'features_modal'
    end
  end

  get 'search/commercial_units', to: 'commercial_units#filter', as: :commercial_units_filter

  # designed to match nestio's API endpoints, so we can feed our data seamlessly to 
  # our public-facing website
  namespace :api, :defaults => {:format => :json} do #, :path => "/", :constraints => {:subdomain => "api"}  do
    namespace :v1 do
      resources :agents
      resources :neighborhoods
      resources :listings
    end
  end

end
