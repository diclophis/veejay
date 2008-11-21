#

#include Yahoo::Music

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
    @videos = []
    if request.post? then
      begin
        Person.transaction do
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
          return redirect_to(profile_url(current_person))
        end
      rescue => problem
      end
    end
  end
  def search
    @videos = []
    unless params[:artist_or_song].blank?
      @videos = Yahoo::Music::Video.search(params[:artist_or_song], {"count" => "50"})
      @videos.delete_if { |video| video.id.blank? or video.id == 0 or video.images.first.nil? }
    end
    render :partial => "profile/results"
  end
end
