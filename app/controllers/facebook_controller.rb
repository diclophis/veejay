#

class FacebookController < ApplicationController
  layout "facebook"
  before_filter :require_facebook_login, :only => :index
  def finish_facebook_login
    #redirect_to(facebook_url)
  end
  def index
    #render_with_facebook_debug_panel
    @user = fbsession.users_getInfo(
      :uids => fbsession.session_user_id,
      :fields => ["first_name","last_name", "pic_square", "status"]
    )
    if current_facebook_person then
      redirect_to(dashboard_url)
    else
      redirect_to(register_url({:anchor => "facebook"}))
    end
  end
  def debug
    return render_with_facebook_debug_panel
  end
  #def require_configuration
  #  @user = FacebookUser.find_by_user_id(fbsession.session_user_id)
  #  redirect_to :action => :configure unless @user
  #end
  
  def configure
    #@user = FacebookUser.find_or_initialize_by_user_id(fbsession.session_user_id)
    #unless fbsession.session_expires
    #  @user.infinite_session = fbsession.session_key
    #  @user.save!
    #end
  end

  def authorize
  end

  def xd_receiver
    if request.post? then
    elsif params[:session] then
      facebook_session = ActiveSupport::JSON.decode(params[:session])
      fbsession.activate_with_previous_session(facebook_session["session_key"])
      @user = fbsession.users_getInfo(
        :uids => facebook_session["uid"],
        :fields => [
          "first_name", "profile_url", "proxied_email", "pic_square", "music"
        ])
      if current_person then
        current_person.facebook_user_id = facebook_session["uid"]
        current_person.save!
      else
        facebook_person = Person.new
        facebook_person.facebook_user_id = facebook_session["uid"]
        facebook_person.nickname = @user.first_name.to_s
        facebook_person.email = @user.proxied_email.to_s
        facebook_person.biography = @user.music.to_s
        session[:facebook_person] = facebook_person
      end
    end
  end

=begin
    #{
    #"action"=>"xd_receiver", 
    #"session"=>"{\"session_key\":\"2.0Zj09bqBGjcVsALRBzcEHA__.86400.1228906800-5005911\",\"uid\":\"5005911\",\"expires\":1228906800,\"secret\":\"mZjtaYQuQtD6_kOCIk2PuA__\",\"sig\":\"2c8bda3a89d58fa9edbe07b1e0cb2bbf\"}", 
    #"controller"=>"facebook",
    #"fb_login"=>nil, "fname"=>"_opener"
    #}
=begin
      @something = fbsession.auth_getSession({
        :v => "1.0",
        :session_key => facebook_session["session_key"],
        #:sig => params["session"]["sig"]
      })
      logger.debug(@something)
      #logger.debug(@user.first_name)
      #logger.debug(@user.proxied_email)
      #logger.debug(@user.profile_url)
      #logger.debug(@user.pic_square)
#Jon
#apps+57567691128.5005911.b8fac565105c0ab2a61333dbcb6ebb8c@proxymail.facebook.com
#http://www.facebook.com/profile.php?id=5005911
#http://profile.ak.facebook.com/v222/1444/24/q5005911_4365.jpg
auth.getSession 
http://www.facebook.com/code_gen.php?v=1.0&api_key=YOUR_API_KEY
require 'facebook_rails_controller_extensions'
session = RFacebook::FacebookWebSession.new('YOUR_API_KEY', 'YOUR_API_SECRET')
FacebookUser.find(:all).each do |user|
  session.activate_with_previous_session(user.infinite_session, user.user_id)
  session.profile_setFBML(:uid => user.user_id, :markup => 'My really dynamic content')
  session.feed_publishActionOfUser(:title => 'added some really dynamic content')
end
def set_user
    @current_fb_user_id = fbsession.session_user_id  #Stores unique
facebook id
    response = fbsession.users_getInfo(:uids =>
[fbsession.session_user_id], :fields => ["first_name", "last_name",
"pic_big"])
    @firstName = response.first_name  #First Name for user
    @lastName = response.last_name  #Last Name for user
    @image = response.pic_big  #Image for user

    if User.find(:all, :conditions =>  @current_fb_user_id)
      #will allready have a user row
    else
      User.new (:fid => @current_fb_user_id )
    end
 end 

canvas page is just like a home page

http://www.facebook.com/authorize.php?api_key=YOUR_API_KEY&v=1.0&ext_perm=PERMISSION_NAME

http://wiki.developers.facebook.com/index.php/Extended_permissions
http://wiki.developers.facebook.com/index.php/Feed.publishUserAction
http://wiki.developers.facebook.com/index.php/Action_Links
http://wiki.developers.facebook.com/index.php/Feed_Story_Guidelines
http://wiki.developers.facebook.com/index.php/Feed

http://wiki.developers.facebook.com/index.php/Account_Linking

http://wiki.developers.facebook.com/index.php/Creating_Your_First_Application

=end

=begin
98.210.154.226 - - [09/Dec/2008:09:21:57 +0000] "GET /facebook/xd_receiver.htm?fb_login&fname=_opener&session=%7B%22session_key%22%3A%222.WNUJgGcII2pyzeSCKC0NYQ__.86400.1228903200-5005911%22%2C%22uid%22%3A%225005911%22%2C%22expires%22%3A1228903200%2C%22secret%22%3A%22PVgKsqEQFlQjwERKYHoO0Q__%22%2C%22sig%22%3A%22346d1df6ee0be4b27a54c9d42f52e166%22%7D&installed=1 HTTP/1.1" 200 237 "http://www.connect.facebook.com/login.php?return_session=1&fbconnect=1&connect_display=popup&api_key=974a573be253946712b3d0ab6f3c5c85&v=1.0&next=http%3A%2F%2Fveejay.tv%2Ffacebook%2Fxd_receiver.htm%3Ffb_login%26fname%3D_opener&cancel_url=http%3A%2F%2Fveejay.tv%2Ffacebook%2Fxd_receiver.htm%23fname%3D_opener%26%257B%2522t%2522%253A3%252C%2522h%2522%253A%2522fbCancelLogin%2522%252C%2522sid%2522%253A%25220.683%2522%257D&channel_url=http%3A%2F%2Fveejay.tv%2Ffacebook%2Fxd_receiver.htm" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.4) Gecko/2008102920 Firefox/3.0.4"
98.210.154.226 - - [09/Dec/2008:09:21:57 +0000] "GET /dashboard HTTP/1.1" 302 97 "http://veejay.tv/facebook/test.html" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.4) Gecko/2008102920 Firefox/3.0.4"
98.210.154.226 - - [09/Dec/2008:09:21:58 +0000] "GET /login HTTP/1.1" 200 1372 "http://veejay.tv/facebook/test.html" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.4) Gecko/2008102920 Firefox/3.0.4"
98.210.154.226 - - [09/Dec/2008:09:21:58 +0000] "GET /javascripts/application.js?1228814093 HTTP/1.1" 200 3394 "http://veejay.tv/login" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.4) Gecko/2008102920 Firefox/3.0.4"
=end

=begin
        <div id="ctl00_Form_FacebookDiv" class="profileInnerContent editAccount">
          <h4>Do you have a Facebook profile?  Bring your profile with you by signing in below.</h4>
          <br />
          <div class="row">
              <center><fb:login-button onclick="GG.SN.sessionOnReady(true);"></fb:login-button></center>
          </div>

          
        </div>

  <script src="http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php" type="text/javascript"></script>
  <script type="text/javascript">FB_RequireFeatures(["XFBML"],function(){FB.Facebook.init("baa677c60bdbb77e990795ba0d27ed71","/Pages/Auth/Connect/xd_receiver.htm");});</script>
  http://wiki.developers.facebook.com/index.php/Extended_permissions
=end




end
