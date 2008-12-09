#

class PeopleController < ApplicationController
  def login
    @new_cookie_flag = false
    if params["openid.mode"] then
      response = openid_consumer.complete(openid_params, url_for(:login))
      pending_person.errors.add(:nickname, "OpenID Failure, please retry") and return render unless response.status == :success
      flash[:notice] = "Please register first..." and return redirect_to({:action => :register, :person => pending_person.attributes}) unless Person.exists?(:nickname => pending_person.nickname)
      return authenticate(Person.find_by_nickname(pending_person.nickname))
    elsif request.post? then
      if params[:person] then
        begin
          raise "is unknown" unless Person.exists?(:nickname => pending_person.nickname)
          person = Person.find_by_nickname(pending_person.nickname)
          raise "does not have an associated identity url" if person.identity_url.blank? 
          response = openid_consumer.begin(person.normalize_identity_url)
          remember_pending_person
          redirect_url = response.redirect_url(root_url, url_for(:login))
          return redirect_to redirect_url
        rescue => problem
          logger.debug(problem.backtrace.join("\n"))
          pending_person.errors.add(:nickname, problem)
        end
      else
        logout_keeping_session!
        person = Person.authenticate(params[:basic_person][:nickname], params[:basic_person][:password])
        if person
          return authenticate(person)
        else
          logger.warn "Failed login for '#{params.inspect}' from #{request.remote_ip} at #{Time.now.utc}"
          basic_person.errors.add(:nickname, "is invalid")
        end
      end
    else
      basic_person.nickname = cookies[:nickname]
      pending_person.nickname = cookies[:nickname]
    end
  end
  def logout
    cookies[:personal_header] = nil
    reset_session
    return redirect_to(root_url)
  end
  def register
    if params["openid.mode"] then
      response = openid_consumer.complete(openid_params, url_for(:register))
      pending_person.errors.add(:identity_url, "OpenID Failure, please retry") and return render unless response.status == :success
      begin
        pending_person.save!
        Mercury.deliver_activation_code(pending_person)
        authenticate(pending_person)
        return redirect_to(remembered_params)
      end
    elsif request.post? then
      logout_keeping_session!
      #@person = Person.new(params[:person])
      basic_person.register! if basic_person && basic_person.valid?
      success = basic_person && basic_person.valid?
      if success && basic_person.errors.empty?
        flash[:success] = "Thanks for signing up!  We're sending you an email with your activation code."
        redirect_back_or_default(root_url)
      #else
      #  flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      #  render :action => 'new'
      end
=begin
      if pending_person.valid? then
        begin
          response = openid_consumer.begin(pending_person.identity_url)
          #if Person.exists?(:identity_url => pending_person.normalize_identity_url) then
          #  redirect_url = response.redirect_url(root_url, url_for(:login))
          #else
            remember_pending_person
            redirect_url = response.redirect_url(root_url, url_for(:register))
          #end
          return redirect_to redirect_url
        rescue => problem
          pending_person.errors.add(:identity_url, problem)
        end
      end
=end
    else
      basic_person
      basic_person.nickname = session[:nickname]
      basic_person.email = session[:email]

      pending_person
      pending_person.identity_url = "Click the OpenID button to pick your service"
      pending_person.nickname = session[:nickname]
      pending_person.email = session[:email]
    end
  end
  def activate
    logout_keeping_session!
    @person = Person.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
      when (!params[:activation_code].blank?) && @person && !@person.active?
        @person.activate!
        flash[:success] = "Signup complete! Please sign in to continue."
        redirect_to(login_url)
      when params[:activation_code].blank?
        flash[:error] = "The activation code was missing.  Please follow the URL from your email."
        redirect_back_or_default(root_url)
    else 
      flash[:error]  = "We couldn't find a person with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_url)
    end
  end
=begin
  def activate
    begin
      person_to_activate = Person.find_by_activation_code(params[:id])
      person_to_activate.activate!
#TODO: double check against current_person?
      return redirect_to(dashboard_url)
    rescue => problem
      flash[:notice] = "There was a problem activating your account"
      return redirect_to(root_url)
    end
  end
=end
  protected
    def basic_person
      unless @basic_person
        @basic_person = remembered_pending_person
        if params[:basic_person] then
          @basic_person.identity_url = params[:basic_person][:identity_url]
          @basic_person.nickname = params[:basic_person][:nickname]
          @basic_person.email = params[:basic_person][:email]
          @basic_person.biography = ""
        end
      end
      @basic_person
    end
    def pending_person
      unless @person
        @person = remembered_pending_person
        if params[:person] then
          @person.identity_url = params[:person][:identity_url]
          @person.nickname = params[:person][:nickname]
          @person.email = params[:person][:email]
          @person.biography = ""
        end
        @person.identity_url = params["openid.identity"] if @person.identity_url.blank?
      end
      @person
    end
    def remembered_pending_person
      remembered = session[:pending_person] || Person.new
      session[:pending_person] = nil
      remembered 
    end
    def remember_pending_person
      session[:pending_person] = pending_person
    end
    def openid_params
      cleaned = params.dup
      cleaned.delete(:controller)
      cleaned.delete(:action)
      cleaned
    end
    def openid_consumer
      @openid_consumer ||= OpenID::Consumer.new(session, OpenID::Store::Filesystem.new("#{RAILS_ROOT}/tmp/openid"))
    end
end

=begin
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    muser = Muser.authenticate(params[:login], params[:password])
    if muser
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_muser = muser
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
=end

=begin
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_cruser, :only => [:suspend, :unsuspend, :destroy, :purge]
  

  # render new.rhtml
  def new
    @cruser = Cruser.new
  end
 
  def create
    logout_keeping_session!
    @cruser = Cruser.new(params[:cruser])
    @cruser.register! if @cruser && @cruser.valid?
    success = @cruser && @cruser.valid?
    if success && @cruser.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    cruser = Cruser.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && cruser && !cruser.active?
      cruser.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a cruser with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def suspend
    @cruser.suspend! 
    redirect_to crusers_path
  end

  def unsuspend
    @cruser.unsuspend! 
    redirect_to crusers_path
  end

  def destroy
    @cruser.delete!
    redirect_to crusers_path
  end

  def purge
    @cruser.destroy
    redirect_to crusers_path
  end
  
  # There's no page here to update or destroy a cruser.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

protected
  def find_cruser
    @cruser = Cruser.find(params[:id])
  end
=end
