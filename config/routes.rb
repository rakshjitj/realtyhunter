Rails.application.routes.draw do
  
  resources :companies do
    resources :offices
  end
  
  get 'static_pages/home'
#  get 'static_pages/help'

  get 'signup'  => 'users#new'
  get 'sessions/new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  
  root :to => 'static_pages#home'
  
  # TODO: clean up this path
  get 'users/batch_new', to: 'users#batch_new', as: :users_batch_new
  post 'users/batch_create', to: 'users#batch_create', as: :users_batch_create
  resources :users
  delete 'users/:id/destroy_image', to: 'users#destroy_image', as: :user_destroy_image
  patch 'users/:id/upload_image', to: 'users#upload_image', as: :user_upload_image
  get 'subordinates/:id', to: 'users#subordinates', as: :user_subordinates
  get 'coworkers/:id', to: 'users#coworkers', as: :user_coworkers
  get 'teams', to: 'users#teams', as: :teams
  patch 'users/:id/admin_approve', to: 'users#admin_approve', as: :admin_approve_user
  patch 'users/:id/admin_unapprove', to: 'users#admin_unapprove', as: :admin_unapprove_user


  resources :account_activations, only: [:edit]
  resources :account_approvals,   only: [:edit]
  resources :added_by_admins,     only: [:edit, :update]
  resources :password_resets,     only: [:new, :create, :edit, :update]

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
