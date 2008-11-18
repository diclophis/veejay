#

class PeopleController < ApplicationController
  def login
    if params["openid.mode"] then
      response = openid_consumer.complete(openid_params, url_for(:login))
      pending_person.errors.add(:nickname, "OpenID Failure, please retry") and return render unless response.status == :success
      flash[:notice] = "Please register first..." and return redirect_to({:action => :register, :person => pending_person.attributes}) unless Person.exists?(:nickname => pending_person.nickname)
      authenticate(Person.find_by_nickname(pending_person.nickname))
      return redirect_to(remembered_params)
    elsif request.post? then
      begin
        raise "is unknown" unless Person.exists?(:nickname => pending_person.nickname)
        response = openid_consumer.begin(Person.find_by_nickname(pending_person.nickname).normalize_identity_url)
        remember_pending_person
        redirect_url = response.redirect_url(root_url, url_for(:login))
        return redirect_to redirect_url
      rescue => problem
        logger.debug(problem.backtrace.join("\n"))
        pending_person.errors.add(:nickname, problem)
      end
    end
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
      if pending_person.valid? then
        begin
          response = openid_consumer.begin(pending_person.identity_url)
          if Person.exists?(:identity_url => pending_person.normalize_identity_url) then
            redirect_url = response.redirect_url(root_url, url_for(:login))
          else
            remember_pending_person
            redirect_url = response.redirect_url(root_url, url_for(:register))
          end
          return redirect_to redirect_url
        rescue => problem
          pending_person.errors.add(:identity_url, problem)
        end
      end
    else
      pending_person
    end
  end
  def activate
    begin
      person_to_activate = Person.find_by_activation_code(params[:id])
      person_to_activate.activate!
#TODO: double check against current_person?
      return redirect_to(bookmarklet_url)
    rescue => problem
      logger.debug(problem)
      flash[:notice] = "There was a problem activating your account"
      return redirect_to(root_url)
    end
  end
  protected
    def pending_person
      unless @person
        @person = remembered_pending_person
        if params[:person] then
          @person.identity_url = params[:person][:identity_url]
          @person.nickname = params[:person][:nickname]
          @person.email = params[:person][:email]
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
