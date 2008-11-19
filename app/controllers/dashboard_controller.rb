#

class DashboardController < ApplicationController
  before_filter :require_person
  def index
    @episodes = Episode.paginate(:page => current_page, :conditions => ["person_id = ?", current_person.id])
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
end
