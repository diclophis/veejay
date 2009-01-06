#JonBardin

class FacebookController < ApplicationController
  layout "facebook"
  protect_from_forgery :except => :authorize
  def index
    if current_person then
      #at the moment, the application is just the dashboard
      redirect_to(dashboard_url)
    else
      #if they are not logged in, redirect them to login
      #it might make sense to send them to register, I
      #have not worked out the flow for this just yet
      redirect_to(login_url)
    end 
  end
  def redirect
    #never reached in this example, but 
    #for sake of completeness make 
    #it do something
    redirect_to(facebook_url)
  end
  def authorize
    #facebook posts data here async.
    #when someone adds your application.
    #you might want to do something 
    #special with this request, I didn't
    if request.post? then
      #just make sure its posted data
    end
  end
  def remove
    #update the user record to remove their facebook id,
    #WIP
  end
  def xd_receiver
    #this is where most of the magic happens
    if request.post? then
      #never happens?
    elsif params[:session] then
      #if there is a value in params[:session]
      #its a json object, that contains the users credentials
      #first we decode it, then stash their uid into a session
      facebook_session = ActiveSupport::JSON.decode(params[:session])
      session[:facebook_user_id] = facebook_session["uid"]
    elsif cookies["974a573be253946712b3d0ab6f3c5c85_user"] then
      session[:facebook_user_id] = facebook_cookie["user"]
    end
  end
  private
    def facebook_cookie
      #do some jazz to get at the facebook cookies
      #note, we _really_ should be checking the signature
      #against our secret... but I don't know how that works yet
      unless @facebook_cookies
        @facebook_cookies = Hash.new { |hash, short_key|
          hash[short_key] = cookies["#{Facebook::KEY}_#{short_key}"]
        }
      end
      @facebook_cookies
    end
end
