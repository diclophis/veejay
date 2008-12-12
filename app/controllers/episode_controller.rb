#

class EpisodeController < ApplicationController
  caches_page :watch
  protect_from_forgery :except => :pop
  before_filter :require_person, :only => [:rate]
  def watch
    @episode = Episode.find(:first, :include => :person, :conditions => ["people.nickname = ? and slug = ?", params[:nickname], params[:slug]])
    unless @episode
      flash[:notice] = "Set Not Found"
      return redirect_to(root_url)
    end
  end
  def pop
    @video = Yahoo::Music::Video.item(params[:video_id]).first
    @artist = Yahoo::Music::Artist.item(@video.artists.first.id).first
    @last_release = @artist.releases.last
    @lyrics = Lyrics.for(@video.artists.first.name, @video.title)
    render :partial => "episode/pop"
  end
  def play
    @type, @remote_id = params[:id].split("-")
    render :partial => @type
  end
  def preview
    @remote_id = params[:id]
    render :layout => "vanilla"
  end
  def rate
    @episode = Episode.find(:first, :include => :person, :conditions => ["people.nickname = ? and slug = ?", params[:nickname], params[:slug]])
    unless @episode
      flash[:notice] = "Set Not Found"
      return redirect_to(root_url)
    end
    rating_value = RatingValue[params[:rating].to_i]
    rating = Rating.new({
      :rater_id => current_person.id,
      :rater_type => current_person.class.to_s,
      :ratable_id => @episode.id,
      :ratable_type => @episode.class.to_s,
      :value_id => rating_value.id
    })
    rating.save!
    flash[:success] = "Rated!"
    redirect_to(episode_url(*@episode.to_param))
  end
end
