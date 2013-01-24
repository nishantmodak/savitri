Savitri::Application.routes.draw do
  mount RedactorRails::Engine => '/redactor_rails'

  devise_for :users
  
  get "/profile/:id" => "users#show", :as => :profile
  
 

  get '/the-light-of-supreme' => "blogs#show", :defaults => { :id => '1', :user_id=>'1' }

  get '/blogs/latest' => "blogs#latest"
  
  resources :blogs

  resources :read

  resources :follows, :only => [:create, :destroy]

  resources :users do
    get "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end
  
  get "savitri/index"

  # resources :users do
  #   resources :posts do
  #     resources :comments
  #   end
  # end

  resources :users do
   resources :blogs, :name_prefix => "user_"
  end

  resources :blogs do
    resources :posts, :name_prefix => "blog_"
  end

  resources :posts do
    resources :comments, :name_prefix => "post_"
  end


  get 'blogs/:blog_id/posts/tags/:tag' , to: 'posts#index' , as: :tag
  
  resources :books
  
  resources :cantos

  resources :stanzas

  resources :lines

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'blogs#home', :as => 'savitri'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
