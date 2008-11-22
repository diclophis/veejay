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
    friend = Person.find_by_nickname(params[:id])
    raise unless friend
    raise if friend.id == current_person.id
    current_person.become_friends_with(friend) 
    flash[:success] = "Subscribed!"
    return redirect_to(profile_url(friend))
  end
  def edit
    @episode = Episode.find_by_id(params[:id])
    @videos = @episode.videos.collect { |video| video.yahoo_video }
    if request.post? then
      begin
        Person.transaction do
          @episode.videos.delete_all
          @episode.videos.clear
          if params[:episode][:video_ids] then
            params[:episode][:video_ids].each { |video_id|
              video = Yahoo::Music::Video.item(video_id).first
              @episode.videos << Video.create({
                :yahoo_id => video.id,
                :yahoo_title => video.title,
                :yahoo_duration => video.duration,
                :yahoo_video => video
              })
              @videos << video
            }
          end
          @episode.title = params[:episode][:title]
          @episode.description = params[:episode][:description]
          current_person.episodes << @episode
          @episode.save!
          flash[:success] = "Saved!"
          return redirect_to(dashboard_url)
        end
      rescue => problem
      end
    end
  end
  def share
    @episode = Episode.find(:first, :include => :person, :conditions => ["people.nickname = ? and slug = ?", params[:nickname], params[:slug]])
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
end
