# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a047736fbed40c89c719438ff6566708'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  MOBILE_USER_AGENTS = 'palm|palmos|palmsource|iphone|blackberry|nokia|phone|midp|mobi|pda|' +
                       'wap|java|nokia|hand|symbian|chtml|wml|ericsson|lg|audiovox|motorola|' +
                       'samsung|sanyo|sharp|telit|tsm|mobile|mini|windows ce|smartphone|' +
                       '240x320|320x320|mobileexplorer|j2me|sgh|portable|sprint|vodafone|' +
                       'docomo|kddi|softbank|pdxgw|j-phone|astel|minimo|plucker|netfront|' +
                       'xiino|mot-v|mot-e|portalmmm|sagem|sie-s|sie-m|android|ipod'

  protected
    def remember_params
      session[:remembered_params] = params
    end
    def remembered_params
      remembered = session[:remembered_params] || {:controller => :welcome, :action => :index}
      session[:remembered_params] = nil
      remembered
    end
    def require_person
      flash[:notice] = "Please login first..." and remember_params and redirect_to login_url unless current_person
    end
    def authenticate (person)
      session[:person_id] = person.id
    end
    def forget
      session.delete(:person_id)
    end
    helper_method :current_person
    def current_person
      if session[:person_id] then
        @current_person ||= Person.find(session[:person_id]) if Person.exists?(session[:person_id])
      else
        false
      end
    end
    helper_method :current_page
    def current_page
      params[:page].to_i < 1 ? 1 : params[:page].to_i
    end
    helper_method :current_per_page
    def current_per_page
      5
    end
    helper_method :recent_people
    def recent_people
      Person.paginate(
        :per_page => 10,
        :page => 1,
        :joins => "JOIN findings ON findings.person_id = people.id",
        :group => "findings.person_id",
        :order => "findings.created_at DESC"
      )
    end
    helper_method :is_mobile?
    def is_mobile?
      request.user_agent.to_s.downcase =~ Regexp.new(MOBILE_USER_AGENTS)
    end
end
