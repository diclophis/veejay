#

class Mercury < ActionMailer::Base
  delivery_method = :sendmail
  def new_features (person)
    recipients person.email
    subject "VeeJay.tv Updates"
    from "mercury@veejay.tv"
    body({:person => person})
  end
  def activation_code (person)
    recipients person.email
    subject "VeeJay.tv Activation"
    from "mercury@veejay.tv"
    body({:person => person})
  end
  def share_redirect (email, message, permalink)
    recipients email
    subject "VeeJay.tv Share"
    from "mercury@veejay.tv"
    body({:email => email, :message => message, :permalink => permalink})
  end
end

=begin
  def signup_notification(cruser)
    setup_email(cruser)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://YOURSITE/activate/#{cruser.activation_code}"
  
  end
  
  def activation(cruser)
    setup_email(cruser)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://YOURSITE/"
  end
  
  protected
    def setup_email(cruser)
      @recipients  = "#{cruser.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[YOURSITE] "
      @sent_on     = Time.now
      @body[:cruser] = cruser
    end
=end
