#

class EpisodeController < ApplicationController
  caches_page :watch
  protect_from_forgery :except => :pop
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
    @type, @remote_id = params[:id].split("-")
    render :layout => "vanilla"
  end
end
