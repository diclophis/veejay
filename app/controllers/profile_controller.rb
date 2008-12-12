#

class ProfileController < ApplicationController
  def index
    @person = Person.find_by_nickname(params[:nickname])
    unless @person
      if current_person then
        return redirect_to(profile_url(current_person))
      else
        return redirect_to(login_url)
      end
    end
    @episodes = Episode.paginate(
      :page => current_page, 
      :per_page => current_per_page, 
      :conditions => ["person_id = ?", @person.id], 
      :order => "created_at desc"
    )
    respond_to { |format|
      format.html
      format.rss
    }
  end
end
