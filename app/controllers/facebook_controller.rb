#

class FacebookController < ApplicationController
  layout "facebook"
  protect_from_forgery :except => :authorize
  def index
    logger.debug(cookies.inspect)
#{"fb_sig_time"=>"1230906175.1304", "fb_sig_in_iframe"=>"1", "fb_sig_in_new_facebook"=>"1", "fb_sig"=>"cc74282a4b502b4f064fcdfdedd82f85", "action"=>"index", "fb_sig_locale"=>"en_US", "fb_sig_session_key"=>"2.1U2oUcxRkS8ZFLWRQdfSVA__.86400.1230994800-1020857150", "controller"=>"facebook", "fb_sig_expires"=>"1230994800", "fb_sig_added"=>"1", "fb_sig_api_key"=>"974a573be253946712b3d0ab6f3c5c85", "fb_sig_profile_update_time"=>"0", "fb_sig_user"=>"1020857150", "fb_sig_ss"=>"UBhtYxlQDlXDBdJGLqIUeQ__"}
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
    end
  end
  def remove
    logger.debug(params)
  end
  def xd_receiver
    if request.post? then
      logger.debug("wtf!!")
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
