Rails.application.routes.draw do

  resources :images
  get 'static_pages/help'
  get 'static_pages/home'

  get 'signup'  => 'users#new'
  get 'sessions/new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  
  root :to => 'static_pages#home'
  
  resources :users do
    collection do
      get 'update_offices'
      get 'batch_new'
      post 'batch_create'
      get 'batch_add_user'
      get 'filter'
    end
    member do 
      delete 'destroy_image'
      post 'upload_image'
      get 'coworkers'
      get 'subordinates'
      post 'admin_approve'
      post 'admin_unapprove'
      post 'admin_kick'
      patch 'new_auth_token'
    end
  end
  
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

  # TODO: consolidate this somehow?
  concern :images_uploadable do
    resources :images, only: [:create, :destroy] do
      collection do
        put 'sort'
      end
    end
  end

  concern :unit_images_uploadable do
    resources :unit_images, only: [:create, :destroy] do
      collection do
        put 'sort'
      end
    end
  end

  resources :buildings, concerns: :images_uploadable do
    get :autocomplete_building_formatted_street_address, :on => :collection
    member do
      get 'delete_modal'
      get 'inaccuracy_modal'
      patch 'send_inaccuracy'
      get 'refresh_images'
    end
    collection do
      get 'filter'
    end
  end
  
  resources :residential_units, concerns: :unit_images_uploadable do
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
      get 'refresh_images'
    end
    collection do
      get 'filter'
      get 'print_list'
      get 'neighborhoods_modal'
      get 'features_modal'
    end
  end

  resources :landlords do
    collection do
      get 'filter'
    end
    member do
      get 'delete_modal'
    end
  end

  resources :neighborhoods

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
      get 'refresh_images'
    end
    collection do
      get 'filter'
      get 'print_list'
      get 'update_subtype'
      # get 'neighborhoods_modal'
      # get 'features_modal'
    end
  end

  #get 'search/landlords', to: 'landlords#filter', as: :landlords_filter
  #get 'search/residential_units', to: 'residential_units#filter', as: :residential_units_filter
  #get 'search/buildings', to: 'buildings#filter', as: :buildings_filter
  #get 'search/commercial_units', to: 'commercial_units#filter', as: :commercial_units_filter

  # designed to match nestio's API endpoints, so we can feed our data seamlessly to 
  # our public-facing website
  namespace :api, :defaults => {:format => :json} do #, :path => "/", :constraints => {:subdomain => "api"}  do
    namespace :v1 do
      resources :agents, only: [:index, :show]
      resources :neighborhoods, only: [:index, :show]
      resources :listings, only: [:index, :show]
    end
  end

end