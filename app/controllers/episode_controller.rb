#

class EpisodeController < ApplicationController
  def watch
    @episode = Episode.find_by_id(params[:id])
  end
  def pop
    @video = Yahoo::Music::Video.item(params[:video_id]).first
    @lyrics = Lyrics.for(@video.artists.first.name, @video.title)
    render :partial => "episode/pop"
  end
end
