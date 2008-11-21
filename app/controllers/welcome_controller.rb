#

class WelcomeController < ApplicationController
  def index
    @popular_videos = Yahoo::Music::Video.published
    @popular_videos.delete_if { |video| video.id.blank? or video.id == 0 }
    @recent_episodes = Episode.paginate(:all, :page => current_page, :per_page => current_per_page, :order => "created_at desc")
  end
  def feed
    respond_to { |format|
      format.html
      format.rss
    }
  end
  def about
  end
  def bookmarklet
    new_findings_url = url_for({:controller => :findings, :action => :new})
    @js = render_to_string(:inline => "
    window.open('#{new_findings_url}?bookmarklet=1&finding[tag_list]=&image[src]='+encodeURIComponent(window.location)+'&image[title]='+encodeURIComponent(document.title),'_blank');
    ").gsub!("\n", "")
    @js = "javascript:(function(){#{@js}})()"
  end
end
