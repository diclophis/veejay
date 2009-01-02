#

class FacebookController < ApplicationController
  layout "facebook"
  protect_from_forgery :except => :authorize
  def index
    logger.debug(cookies.inspect)
    render :text => "profile app coming soon"
  end
  def redirect
    redirect_to(facebook_url)
  end
  def authorize
    if request.post? then
      logger.debug(params)
    end
  end
  def remove
    logger.debug(params)
  end
  def xd_receiver
    if request.post? then
    elsif params[:session] then
      facebook_session = ActiveSupport::JSON.decode(params[:session])
      session[:facebook_user_id] = facebook_session["uid"]
    elsif cookies["974a573be253946712b3d0ab6f3c5c85_user"] then
      session[:facebook_user_id] = cookies["974a573be253946712b3d0ab6f3c5c85_user"]
    end
  end
end
