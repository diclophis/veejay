#

class Person < ActiveRecord::Base
  has_many_friends
  has_many :findings
  has_many :images, :through => :findings
  has_many :last_three_images, :source => :image, :through => :findings, :limit => 3, :order => 'created_at DESC'
  before_validation_on_create :assign_activation_code
  before_validation :normalize_identity_url
  validates_presence_of :identity_url
  validates_as_uri :identity_url
  validates_as_email :email
  validates_presence_of :email
  validates_presence_of :nickname
  validates_format_of :nickname, :with => /^[a-zA-Z0-9]+$/
  validates_uniqueness_of :nickname
  validates_presence_of :activation_code
  def assign_activation_code
    self.activation_code = UUID.random_create.to_s
  end
  def activate!
    self.activated = true
    save!
  end
  def normalize_identity_url
    begin
      unless identity_url.index("http") == 0 then
        self.identity_url = "http://#{identity_url}"
      end
      self.identity_url = OpenID::normalize_url(identity_url)
    rescue
      self.identity_url = ""
    end
  end
  def to_s
    nickname
  end
  def to_param
    nickname
  end
end
