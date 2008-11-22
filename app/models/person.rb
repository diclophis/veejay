#

class Person < ActiveRecord::Base
  has_many_friends
  #has_many :findings
  #has_many :images, :through => :findings
  #has_many :last_three_images, :source => :image, :through => :findings, :limit => 3, :order => 'created_at DESC'
  has_many :episodes
  before_validation_on_create :assign_activation_code
  before_validation :normalize_identity_url
  validates_presence_of :identity_url
  validates_as_uri :identity_url
  validates_as_email :email
  validates_presence_of :email
  validates_presence_of :nickname
  validates_format_of :nickname, :with => /^[a-zA-Z0-9]+$/, :message => "may only be letters (a-z,A-Z) and numbers (0-9) and cannot contain spaces"
  validates_each :nickname do |record, key, value|
    record.errors.add(key, "is reserved") if %w{redirect logout pop activate stylesheets images javascripts dashboard register login about page update edit subscribe sets rss create search}.include?(value)
  end
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
  def gravatar_url
    hash = MD5::md5(self.email)
    "http://www.gravatar.com/avatar/#{hash}"
  end
end
