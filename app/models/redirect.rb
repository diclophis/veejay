#

class Redirect < ActiveRecord::Base
  serialize :nonce
  belongs_to :person
  before_validation_on_create :uniqify_permalink
  def uniqify_permalink
    existing = Redirect.count(:conditions => ["permalink like ?", self.permalink])
    if existing > 0 then
      self.permalink += "-#{existing+1}"
    end
  end
end
