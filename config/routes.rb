ActionController::Routing::Routes.draw do |map|
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
  #map.resource :person, :member => { :complete => :get }

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "welcome"
  map.page "/page/:page", :controller => "welcome", :action => "index"

  map.episode "/:nickname/watch/:slug", :controller => "episode", :action => "watch"
  map.share "/:nickname/share/:slug", :controller => "episode", :action => "share"

  map.login '/login', :controller => "people", :action => "login"
  map.logout '/logout', :controller => "people", :action => "logout"
  map.register '/register', :controller => "people", :action => "register"
  map.about '/about', :controller => "welcome", :action => "about"
  map.faq '/faq', :controller => "welcome", :action => "faq"


  #map.cloud '/cloud', :controller => "welcome", :action => "cloud"
  #map.random '/random', :controller => "welcome", :action => "random"
  #map.random '/plist_of_images_to_rate', :controller => "welcome", :action => "plist_of_images_to_rate"

  #map.philosophy '/philosophy', :controller => "welcome", :action => "philosophy"
  #map.findings '/findings', :controller => "welcome", :action => "findings"
  #map.image '/image/:permalink', :controller => "welcome", :action => "image"
  #map.similarities '/similarities/:permalink', :controller => "welcome", :action => "similarities"
  map.dashboard '/dashboard', :controller => "dashboard", :action => "index"
  map.update '/update', :controller => "dashboard", :action => "update"
  map.edit '/edit/:id', :controller => "dashboard", :action => "edit"
  map.subscribe '/subscribe/:id', :controller => "dashboard", :action => "subscribe"
  map.sets '/sets/:nickname', :controller => "profile", :action => "index", :format => "rss"
  map.create '/create', :controller => "profile", :action => "create"
  map.search '/search', :controller => "profile", :action => "search"
  map.pop '/pop', :controller => "episode", :action => "pop"
  map.preview '/preview/:id', :controller => "episode", :action => "preview"
  map.rss '/rss', :controller => "welcome", :action => "index", :format => "rss"
  map.activate '/activate/:id', :controller => "people", :action => "activate"

  # See how all your routes lay out with "rake routes"
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
  map.profile '/:nickname', :controller => "profile", :action => "index"
end
