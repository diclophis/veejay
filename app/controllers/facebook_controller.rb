#JonBardin

class FacebookController < ApplicationController
  layout "facebook"
  protect_from_forgery :except => :authorize
  def index
    #display application
    logger.debug(cookies.inspect)
    if current_person then
      redirect_to(dashboard_url)
    else
      redirect_to(login_url)
    end 
  end
  def redirect
    redirect_to(facebook_url)
  end
  def authorize
    if request.post? then
      logger.debug(params)
      #do something special?
    end
  end
  def remove
    logger.debug(params)
    #update the user record
  end
  def xd_receiver
    if request.post? then
      #never happens?
    elsif params[:session] then
      logger.debug("is new here")
      facebook_session = ActiveSupport::JSON.decode(params[:session])
      session[:facebook_user_id] = facebook_session["uid"]
    elsif cookies["974a573be253946712b3d0ab6f3c5c85_user"] then
      logger.debug("was here before")
      session[:facebook_user_id] = cookies["974a573be253946712b3d0ab6f3c5c85_user"]
    end
  end
end
