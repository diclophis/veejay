#

class DashboardController < ApplicationController
  before_filter :require_person
  def index
    @episodes = Episode.paginate(
      :page => current_page, 
      :per_page => current_per_page, 
      :conditions => ["person_id = ?", current_person.id], 
      :order => "created_at desc"
    )
    if request.post? then
      Person.transaction do
        begin
          current_person.biography = params[:current_person][:biography]
          current_person.save!
          flash.now[:success] = "Saved!"
        rescue => problem
        end
      end
    end
    respond_to { |format|
      format.html
      format.rss
    }
  end
  def subscribe
    begin
      friend = Person.find_by_nickname(params[:id])
      raise unless friend
      raise if friend.id == current_person.id
      current_person.become_friends_with(friend) 
      flash[:success] = "Subscribed!"
      return redirect_to(dashboard_url)
    rescue => problem
      flash[:notice] = "You cannot subscribe to yourself"
      return redirect_to(dashboard_url)
    end
  end
  def create
    @episode = Episode.new
    if request.post? then
      begin
        Person.transaction do
          @episode.total_duration = 0
          if params[:episode][:videos] then
            params[:episode][:videos].each_with_index { |video_as_yaml, index|
              remote_video = YAML.load(video_as_yaml)
              @episode.videos << Video.create({
                :comment => params[:episode][:comments][index],
                :remote_video => remote_video
              })
              @episode.total_duration += remote_video.duration
            }
          end
          @episode.title = params[:episode][:title]
          @episode.description = params[:episode][:description]
          current_person.episodes << @episode
          @episode.save!
          flash[:success] = render_to_string({:partial => "shared/created_set"}) 
          return redirect_to(dashboard_url)
        end
      rescue => problem
        logger.debug(problem)
      end
    end
  end
  def search
    @videos = []
    unless params[:artist_or_song].blank?
      @videos = RemoteVideo.search(params[:artist_or_song])
    end
    render :partial => "dashboard/results"
  end
  def edit
    @episode = Episode.find_by_id(params[:id])
    unless @episode.person == current_person
      flash[:notice] = "This Is Not Your Video"
      return redirect_to(dashboard_url)
    end
    #@videos = @episode.videos.collect { |video| video.yahoo_video }
    if request.post? then
      begin
        Person.transaction do
          @episode.videos.delete_all
          @episode.videos.clear
          @episode.total_duration = 0
          if params[:episode][:videos] then
            params[:episode][:videos].each_with_index { |video_as_yaml, index|
              remote_video = YAML.load(video_as_yaml)
              @episode.videos << Video.create({
                :comment => params[:episode][:comments][index],
                :remote_video => remote_video
              })
              @episode.total_duration += remote_video.duration
            }
          end
          @episode.title = params[:episode][:title]
          @episode.description = params[:episode][:description]
          current_person.episodes << @episode
          @episode.save!
          flash[:success] = render_to_string({:partial => "shared/created_set"}) 
          return redirect_to(dashboard_url)
        end
      rescue => problem
      end
    end
  end
  def share
    @episode = Episode.find(:first, :include => :person, :conditions => ["people.nickname = ? and slug = ?", params[:nickname], params[:slug]])
    unless @episode.person == current_person
      flash[:notice] = "This Is Not Your Video"
      return redirect_to(dashboard_url)
    end
    @good_emails = @bad_emails = []
    if request.post? then
      begin
        Person.transaction do
          @good_emails, @bad_emails = EmailParser.parse(params[:emails])
          raise if @good_emails.empty?
          raise unless @bad_emails.empty?
          current_person.email_autocompletions ||= []
          @good_emails.collect { |email_autocompletion|
            current_person.email_autocompletions << "#{email_autocompletion.name} #{email_autocompletion.address}".strip
          }
          current_person.email_autocompletions.uniq!
          current_person.email_autocompletions.delete_if(&:blank?)
          current_person.save!
          @good_emails.each { |good_email|
            redirect = Redirect.create({
              #/redirect/bob-to-something-else-for-diclophis
              :permalink => Slugalizer.slugalize(good_email.local) + "-to-" + @episode.slug + "-for-" + Slugalizer.slugalize(current_person.nickname),
              :person_id => current_person.id,
              :nonce => {:email => good_email.address, :nickname => good_email.local},
              :nonce_url => episode_url(*@episode.to_param),
              :default_url => episode_url(*@episode.to_param),
              :expires_on => 30.days.from_now
            })
            Mercury.deliver_share_redirect(good_email, params[:message], redirect.permalink)
          }
          flash[:success] = render_to_string({:partial => "shared/shared_set"}) 
          return redirect_to(dashboard_url)
        end
      rescue => problem
        logger.debug(problem)
        flash.now[:error] = render_to_string({:partial => "shared/emails_error"})
      end
    end
  end
  def email_autocompletions
    email_autocompletions = current_person.email_autocompletions || []
    render :text => email_autocompletions.collect { |email_autocomplete|
      {
        :value => "#{email_autocomplete}",
        :caption => "#{email_autocomplete}"
      }
    }.to_json
  end
  def delete
    @episode = Episode.find_by_id(params[:id])
    unless @episode.person == current_person
      flash[:notice] = "This Is Not Your Video"
      return redirect_to(dashboard_url)
    end
    @episode.destroy
    flash[:success] = "Success!  Set has been deleted."
    return redirect_to(dashboard_url)
  end
end
