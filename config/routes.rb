#JonBardin

ActionController::Routing::Routes.draw do |map|
  #some basic public actions
  map.root :controller => "welcome"
  map.page "/page/:page", :controller => "welcome", :action => "index"
  map.about '/about', :controller => "welcome", :action => "about"
  map.faq '/faq', :controller => "welcome", :action => "faq"
  map.episode "/:nickname/watch/:slug", :controller => "episode", :action => "watch"
  map.rate "/:nickname/rate/:slug/:rating", :controller => "episode", :action => "rate"
  map.share "/:nickname/share/:slug", :controller => "dashboard", :action => "share"
  map.pop '/pop', :controller => "episode", :action => "pop"

  #all of the "facebook connect" actions
  map.facebook "/facebook", :controller => "facebook", :action => "index"
  map.facebook_xd_receiver "/facebook/xd_receiver", :controller => "facebook", :action => "xd_receiver"
  map.facebook_redirect "/facebook/redirect", :controller => "facebook", :action => "redirect"
  map.facebook_authorize "/facebook/authorize", :controller => "facebook", :action => "authorize"
  map.facebook_remove "/facebook/authorize", :controller => "facebook", :action => "remove"

  #these are all of the "gateway" actions, a user transitions to/from authenticated states in one of these
  map.login '/login', :controller => "people", :action => "login"
  map.logout '/logout', :controller => "people", :action => "logout"
  map.register '/register', :controller => "people", :action => "register"
  map.activate '/activate/:activation_code', :controller => "people", :action => "activate"
  map.redirect "/redirect/:permalink", :controller => "welcome", :action => "redirect"

  #we need a user for these actions
  map.dashboard '/dashboard', :controller => "dashboard", :action => "index"
  map.edit '/dashboard/edit/:id', :controller => "dashboard", :action => "edit"
  map.delete "/dashboard/delete/:id", :controller => "dashboard", :action => "delete"
  map.subscribe '/dashboard/subscribe/:id', :controller => "dashboard", :action => "subscribe"
  map.create '/dashboard/create', :controller => "dashboard", :action => "create"
  map.search '/dashboard/search', :controller => "dashboard", :action => "search"
  map.preview '/dashboard/preview/:id', :controller => "episode", :action => "preview"
  map.email_autocompletions "/dashboard/email_autocompletions", :controller => "dashboard", :action => "email_autocompletions"
  
  #the rss stuff
  map.sets '/sets/:nickname', :controller => "profile", :action => "index", :format => "rss"
  map.rss '/rss', :controller => "welcome", :action => "index", :format => "rss"

  #this is the "public profile"
  map.profile '/:nickname', :controller => "profile", :action => "index"
end
