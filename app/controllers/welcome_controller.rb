#

class WelcomeController < ApplicationController
  caches_page :index, :about, :faq
  def index
    @popular_videos = Yahoo::Music::Video.published
    @popular_videos.delete_if { |video| video.id.blank? or video.id == 0 }
    @recent_episodes = Episode.paginate(:all, :page => current_page, :per_page => current_per_page, :order => "created_at desc")
  end
  def about
  end
  def faq
  end
end
