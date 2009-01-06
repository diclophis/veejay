#JonBardin
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
# There is some stuff in here for title control, pagination, but most importantly
# authentication :authenticate, :current_facebook_person, current_person
# AuthenticatedSystem is provided by the restful_authentication plugin

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper_method :current_facebook_person

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a047736fbed40c89c719438ff6566708'
 
  before_filter :determine_title

  #security_components :security_policy, :access_control => [:login_required], :authentication => [:by_cookie_token, :by_password]
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password

  MOBILE_USER_AGENTS = 'palm|palmos|palmsource|iphone|blackberry|nokia|phone|midp|mobi|pda|' +
                       'wap|java|nokia|hand|symbian|chtml|wml|ericsson|lg|audiovox|motorola|' +
                       'samsung|sanyo|sharp|telit|tsm|mobile|mini|windows ce|smartphone|' +
                       '240x320|320x320|mobileexplorer|j2me|sgh|portable|sprint|vodafone|' +
                       'docomo|kddi|softbank|pdxgw|j-phone|astel|minimo|plucker|netfront|' +
                       'xiino|mot-v|mot-e|portalmmm|sagem|sie-s|sie-m|android|ipod'

  protected
    def determine_title
      @title = "VeeJay.tv"
    end

    helper_method :current_page
    def current_page
      params[:page].to_i < 1 ? 1 : params[:page].to_i
    end
    helper_method :current_per_page
    def current_per_page
      6
    end
end
