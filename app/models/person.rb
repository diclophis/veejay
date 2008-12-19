#

class Person < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include AASM
  attr_accessible :nickname, :email, :identity_url, :password, :password_confirmation
  serialize :email_autocompletions
  has_many_friends
  has_many :episodes, :dependent => :destroy
  validates_as_email :email
  validates_presence_of :email
  validates_presence_of :nickname
  validates_length_of :nickname, :within => 3..40
  validates_format_of :nickname, :with => /^[a-zA-Z0-9]+$/, :message => "may only be letters (a-z,A-Z) and numbers (0-9)"
  validates_uniqueness_of :nickname
  validates_uniqueness_of :facebook_user_id, :if => Proc.new { |person| !person.facebook_user_id.blank? }
  validates_each :nickname do |record, key, value|
    record.errors.add(key, "is reserved") if %w{redirect logout pop activate stylesheets images javascripts dashboard register login about page update edit subscribe sets rss create search}.include?(value)
  end
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :passive
  aasm_state :pending, :enter => :make_activation_code
  aasm_state :active,  :enter => :do_activate
  aasm_state :suspended
  aasm_state :deleted, :enter => :do_delete
  aasm_event :register do
    transitions :from => :passive, :to => :pending #, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  aasm_event :activate do
    transitions :from => :pending, :to => :active 
  end
  aasm_event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  aasm_event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end
  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end
  def password_required?
    if identity_url.blank? and facebook_user_id.blank? then
      (crypted_password.blank? || !password.blank?)
    else
      false
    end
  end
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
  def recently_activated?
    @activated
  end
  def active?
    activation_code.nil?
  end
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
  def do_delete
    self.deleted_at = Time.now.utc
  end
  def do_activate
    @activated = true
    self.activated_at = Time.now.utc
    self.deleted_at = self.activation_code = nil
  end
end
