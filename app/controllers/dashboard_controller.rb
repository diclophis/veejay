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
          logger.debug(@good_emails.inspect)
          logger.debug(@bad_emails.inspect)
          raise if @good_emails.empty?
          raise unless @bad_emails.empty?
          current_person.email_autocompletions = []
          current_person.email_autocompletions += @good_emails.collect { |email_autocomplete|
            "#{email_autocomplete.name} #{email_autocomplete.address}".strip!
          }
          current_person.email_autocompletions.uniq!
          current_person.save!
          @good_emails.each { |good_email|
            Mercury.deliver_share_redirect(good_email, params[:message], "wang-chung")
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
=begin
[{"caption":"Manuel Mujica Lainez","value":4},{"caption":"Gustavo Nielsen","value":3},{"caption":"Silvina Ocampo","value":3},{"caption":"Victoria Ocampo", "value":3},{"caption":"Hector German Oesterheld", "value":3},{"caption":"Olga Orozco", "value":3},{"caption":"Juan L. Ortiz", "value":3},{"caption":"Alicia Partnoy", "value":3},{"caption":"Roberto Payro", "value":3},{"caption":"Ricardo Piglia", "value":3},{"caption":"Felipe Pigna", "value":3},{"caption":"Alejandra Pizarnik", "value":3},{"caption":"Antonio Porchia", "value":3},{"caption":"Juan Carlos Portantiero", "value":3},{"caption":"Manuel Puig", "value":3},{"caption":"Andres Rivera", "value":3},{"caption":"Mario Rodriguez Cobos", "value":3},{"caption":"Arturo Andres Roig", "value":3},{"caption":"Ricardo Rojas", "value":3}]
=end
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
