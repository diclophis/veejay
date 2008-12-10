#

class ProfileController < ApplicationController
  before_filter :require_person, :only => [:create, :search]
  def index
    @person = Person.find_by_nickname(params[:nickname])
    unless @person
      if current_person then
        return redirect_to(profile_url(current_person))
      else
        return redirect_to(login_url)
      end
    end
    @episodes = Episode.paginate(
      :page => current_page, 
      :per_page => current_per_page, 
      :conditions => ["person_id = ?", @person.id], 
      :order => "created_at desc"
    )
    respond_to { |format|
      format.html
      format.rss
    }
  end
  def create
    @episode = Episode.new
    if request.post? then
      begin
        Person.transaction do
          if params[:episode][:videos] then
            params[:episode][:videos].each_with_index { |video_as_yaml, index|
              remote_video = YAML.load(video_as_yaml)
              @episode.videos << Video.create({
                :comment => params[:episode][:comments][index],
                :remote_video => remote_video
              })
            }
          end
          @episode.total_duration = 0
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
    render :partial => "profile/results"
  end
end
