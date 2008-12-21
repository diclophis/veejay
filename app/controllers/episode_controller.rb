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
    @lyrics = {}
    @artists = {}
    @episode.videos.each { |video|
      if video.remote_video.artist_names.first then
        @artists[video.remote_video.title] = RemoteArtist.search(video.remote_video.artist_names.first).first
      else
        @artists[video.remote_video.title] = RemoteArtist.search(video.remote_video.title).first
      end
      @lyrics[video.remote_video.title] = Lyrics.for(video.remote_video.artist_names.first, video.remote_video.title)
    }
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
    unless @episode.rated?(current_person)
      rating_value = RatingValue[params[:rating].to_i]
      rating = Rating.new({
        :rater_id => current_person.id,
        :rater_type => current_person.class.to_s,
        :ratable_id => @episode.id,
        :ratable_type => @episode.class.to_s,
        :value_id => rating_value.id
      })
      rating.save!
      @episode.rating = @episode.rating!
      @episode.ratings_count = Rating.count({:conditions => ["ratable_id = ? and ratable_type = ?", @episode.id, @episode.class.to_s]})
      @episode.save!
    end
    redirect_to(episode_url(*@episode.to_param))
  end
end
