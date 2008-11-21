#

class EpisodeController < ApplicationController
  def watch
    @episode = Episode.find(:first, :include => :person, :conditions => ["people.nickname = ? and slug = ?", params[:nickname], params[:slug]])
  end
  def pop
    @video = Yahoo::Music::Video.item(params[:video_id]).first
    @artist = Yahoo::Music::Artist.item(@video.artists.first.id).first
    @last_release = @artist.releases.last
    #@mtv_artist = MTV::Music::Artist.new(@artist.name)
    @lyrics = Lyrics.for(@video.artists.first.name, @video.title)
    render :partial => "episode/pop"
  end
  def preview
    @videos = Yahoo::Music::Video.item(params[:id])
    render :layout => "vanilla"
  end
end
