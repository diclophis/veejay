#

class PeopleController < ApplicationController
  def login
    return authenticate(current_facebook_person) if current_facebook_person
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
          return redirect_to(redirect_url)
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
      if session[:return_to] then
        case session[:return_to]
          when /rate/
            flash.now[:notice] = render_to_string({:partial => "shared/rating_notice"})
        else
          flash.now[:notice] = "You need to be logged in to do that"
        end
      end
      basic_person.nickname = cookies[:nickname]
      pending_person.nickname = cookies[:nickname]
    end
  end
  def logout
    cookies[:personal_header] = nil
    if current_facebook_person then
      #maybe do something special with the facebook data?
    end
    reset_session
    return redirect_to(root_url)
  end
  def register
    if params["openid.mode"] then
      response = openid_consumer.complete(openid_params, register_url)
      pending_person.errors.add(:identity_url, "OpenID Failure, please retry") and return render unless response.status == :success
      begin
        pending_person.register! if pending_person && pending_person.valid?
        success = pending_person && pending_person.valid?
        if success && pending_person.errors.empty?
          flash[:success] = "Thanks!  Please check your email to verify your email address."
          return authenticate(pending_person)
        else
          basic_person.password = basic_person.password_confirmation = nil
        end
      end
    elsif request.post? then
      if params[:facebook_person] then
        logout_keeping_session!
        facebook_person.register! if facebook_person && facebook_person.valid?
        success = facebook_person && facebook_person.valid?
        if success && facebook_person.errors.empty?
          flash[:success] = "Thanks!  Please check your email to verify your email address."
          return authenticate(facebook_person)
        else
          logger.debug("facebook error")
          logger.debug(session.inspect)
          logger.debug(facebook_person.inspect)
        end
      elsif params[:person] then
        if pending_person.valid? then
          begin
            response = openid_consumer.begin(pending_person.identity_url)
            remember_pending_person
            redirect_url = response.redirect_url(root_url, url_for(:register))
            return redirect_to(redirect_url)
          rescue => problem
            pending_person.errors.add(:identity_url, problem)
          end
        end
      else
        logout_keeping_session!
        basic_person.register! if basic_person && basic_person.valid?
        success = basic_person && basic_person.valid?
        if success && basic_person.errors.empty?
          flash[:success] = "Thanks!  Please check your email to verify your email address."
          return authenticate(basic_person)
        else
          basic_person.password = basic_person.password_confirmation = nil
        end
      end
    else
      basic_person
      basic_person.nickname = session[:nickname]
      basic_person.email = session[:email]
      pending_person
      pending_person.nickname = session[:nickname]
      pending_person.email = session[:email]
      current_facebook_person
      facebook_person
      if request.xhr? then
        return render({:partial => "people/facebook"})
      elsif current_facebook_person
        return redirect_to(login_url)
      end
    end
  end
  def activate
    logout_keeping_session!
    @person = Person.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
      when (!params[:activation_code].blank?) && @person && !@person.active?
        @person.activate!
        flash[:success] = "Signup complete! Please sign in to continue."
        return authenticate(@person)
      when params[:activation_code].blank?
        flash[:error] = "The activation code was missing.  Please follow the URL from your email."
        redirect_back_or_default(root_url)
    else 
      flash[:error]  = "We couldn't find a person with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_url)
    end
  end
  protected
    def determine_title
      case params[:action]
        when "register"
          @title = "Register for VeeJay.tv"
        when "login"
          @title = "Login to VeeJay.tv"
      else
        super
      end
    end
    def basic_person
      unless @basic_person
        @basic_person = remembered_pending_person
        if params[:basic_person] then
          @basic_person.identity_url = params[:basic_person][:identity_url]
          @basic_person.nickname = params[:basic_person][:nickname]
          @basic_person.email = params[:basic_person][:email]
          @basic_person.password = params[:basic_person][:password]
          @basic_person.password_confirmation = params[:basic_person][:password_confirmation]
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
    def facebook_person
      unless @facebook_person
        if session[:facebook_user_id] then
          @facebook_person = Person.new
          @facebook_person.facebook_user_id = session[:facebook_user_id]
          if params[:facebook_person] then
            @facebook_person.nickname = params[:facebook_person][:nickname]
            @facebook_person.email = params[:facebook_person][:email]
          end
        end
      end
      @facebook_person
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
