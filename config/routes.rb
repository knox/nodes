ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.signup '/signup', :controller => 'user/profiles', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'user/activations', 
    :action => 'activate', :activation_code => nil
  map.forgot_password '/forgot_password', :controller => 'user/passwords', :action => 'new'  
  map.reset_password '/reset_password/:id', :controller => 'user/passwords', :action => 'edit', :id => nil  
  map.resend_activation '/resend_activation', :controller => 'user/activations', :action => 'new'

  map.namespace :admin do |admin|
    admin.resources :controls
    admin.resources :mailings
    admin.resources :states
    admin.resources :users do |users|
      users.resources :roles
    end    
  end
  
  map.namespace :user do |user|
    user.resources :activations
    user.resources :passwords
    user.resources :profiles do |profiles|
      profiles.resources :password_settings
    end
  end    

  map.resource  :session
  
  map.resources :people, :singular => 'people'

  map.resources :subnets #, :has_many => :nodes
  
  map.map 'nodes/georss', :controller => :nodes, :action => :georss
  map.map 'nodes/kml', :controller => :nodes, :action => :kml
  map.map 'nodes/wfs', :controller => :nodes, :action => :wfs
  map.resources :nodes 

  map.map 'map', :controller => 'map'
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "nodes"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
