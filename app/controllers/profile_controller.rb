#

class ProfileController < ApplicationController
  def index
    @person = Person.find_by_nickname(params[:nickname])
    @episodes = Episode.paginate(:page => current_page, :conditions => ["person_id = ?", @person.id])
  end
  def create
    @episode = Episode.new
  end
  def search
    @videos = Yahoo::Music::Video.search(params[:artist_or_song], {"count" => "50"})
    @videos.delete_if { |video| video.id.blank? or video.id == 0 or video.images.first.nil? }
    render :partial => "profile/results"
  end
end
