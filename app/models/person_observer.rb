#

class PersonObserver < ActiveRecord::Observer
  def after_create(person)
    #CruserMailer.deliver_signup_notification(cruser)
    Mercury.deliver_activation_code(person)
  end
  def after_save(cruser)
    #CruserMailer.deliver_activation(cruser) if cruser.recently_activated?
  end
end
