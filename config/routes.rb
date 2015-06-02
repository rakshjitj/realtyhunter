Rails.application.routes.draw do

  resources :building_amenities
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

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
