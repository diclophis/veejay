#

class EpisodeController < ApplicationController
  caches_page :watch
  protect_from_forgery :except => :pop
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
  def share
    @episode = Episode.find(:first, :include => :person, :conditions => ["people.nickname = ? and slug = ?", params[:nickname], params[:slug]])
    @good_emails = @bad_emails = []
    if request.post? then
      begin
        Person.transaction do
          @good_emails, @bad_emails = EmailParser.parse(params[:emails])
          logger.debug(@good_emails.inspect)
          logger.debug(@bad_emails.inspect)
          raise if @good_emails.empty?
          raise unless @bad_emails.empty?
          flash[:success] = render_to_string({:partial => "shared/shared_set"}) 
          return redirect_to(dashboard_url)
        end
      rescue => problem
        flash[:error] = render_to_string({:partial => "shared/emails_error"})
      end
    end
  end
end
