#

class Person < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  serialize :email_autocompletions
  has_many_friends
  has_many :episodes

  #before_validation_on_create :assign_activation_code
  #before_validation :normalize_identity_url
  #validates_presence_of :identity_url
  #validates_as_uri :identity_url
  validates_as_email :email
  validates_presence_of :email
  validates_presence_of :nickname
  validates_length_of :nickname, :within => 3..40
  validates_format_of :nickname, :with => /^[a-zA-Z0-9]+$/, :message => "may only be letters (a-z,A-Z) and numbers (0-9) and cannot contain spaces"
  validates_uniqueness_of :nickname
  validates_each :nickname do |record, key, value|
    record.errors.add(key, "is reserved") if %w{redirect logout pop activate stylesheets images javascripts dashboard register login about page update edit subscribe sets rss create search}.include?(value)
  end
  validates_uniqueness_of :nickname
  #validates_presence_of :activation_code

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :nickname, :email, :identity_url, :password, :password_confirmation

  #validates_presence_of     :login
  #validates_length_of       :login,    :within => 3..40
  #validates_uniqueness_of   :login
  #validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message
  #validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  #validates_length_of       :name,     :maximum => 100
  #validates_presence_of     :email
  #validates_length_of       :email,    :within => 6..100 #r@a.wk
  #validates_uniqueness_of   :email
  #validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  def make_activation_code
    self.activation_code = UUID.random_create.to_s
  end
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
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
    "http://www.gravatar.com/avatar/#{hash}?d=identicon"
  end
  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(nickname, password)
    return nil if nickname.blank? || password.blank?
    u = find :first, :conditions => ['nickname = ? and activated_at IS NOT NULL', nickname] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  def nickname=(value)
    write_attribute :nickname, (value ? value.downcase : nil)
  end
  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
#  protected
#    
#    def make_activation_code
#        self.activation_code = self.class.make_token
#    end
end
