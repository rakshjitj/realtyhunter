Rails.application.routes.draw do

  resources :building_amenities
  resources :building_amenities
  get 'static_pages/help'

  get 'signup'  => 'users#new'
  get 'sessions/new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  
  root :to => 'static_pages#home'
  
  # TODO: clean up this path
  get 'update_offices', to: 'users#update_offices', as: 'update_offices'
  get 'users/batch_new', to: 'users#batch_new', as: :users_batch_new
  post 'users/batch_create', to: 'users#batch_create', as: :users_batch_create
  get 'users/batch_add_user', to: 'users#batch_add_user', as: :users_batch_add_user
  resources :users
  delete 'users/:id/destroy_image', to: 'users#destroy_image', as: :user_destroy_image
  patch 'users/:id/upload_image', to: 'users#upload_image', as: :user_upload_image
  get 'subordinates/:id', to: 'users#subordinates', as: :user_subordinates
  get 'coworkers/:id', to: 'users#coworkers', as: :user_coworkers
  post 'users/:id/admin_approve', to: 'users#admin_approve', as: :admin_approve_user
  post 'users/:id/admin_unapprove', to: 'users#admin_unapprove', as: :admin_unapprove_user
  post 'users/:id/admin_kick', to: 'users#admin_kick', as: :admin_kick_user
  
  resources :account_activations, only: [:edit]
  resources :account_approvals,   only: [:edit]
  resources :added_by_admins,     only: [:edit, :update]
  resources :password_resets,     only: [:new, :create, :edit, :update]
 
  resources :companies do
    resources :offices
  end
  get 'employees/:id', to: 'companies#employees', as: :company_employees
  get 'companies/:id/managers', to: 'companies#managers', as: :company_managers
  get 'companies/:company_id/offices/:id/managers', to: 'offices#managers', as: :office_managers
  get 'companies/:company_id/offices/:id/agents', to: 'offices#agents', as: :office_agents

  resources :buildings
  get 'search/buildings', to: 'buildings#filter', as: :buildings_filter
  get 'buildings/:id/delete_modal', to: 'buildings#delete_modal', as: :building_delete_modal
  get 'buildings/:id/inaccuracy_modal', to: 'buildings#inaccuracy_modal', as: :building_inaccuracy_modal
  patch 'buildings/:id/send_inaccuracy', to: 'buildings#send_inaccuracy', as: :building_send_inaccuracy
  
  resources :residential_units
  
  resources :landlords
  get 'search/landlords', to: 'landlords#filter', as: :landlords_filter
  get 'landlords/:id/delete_modal', to: 'landlords#delete_modal', as: :landlord_delete_modal

  resources :neighborhoods
  get 'static_pages/home'

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
