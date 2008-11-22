#

class Mercury < ActionMailer::Base
  delivery_method = :sendmail
  def activation_code (person)
    recipients person.email
    subject "VeeJay.tv Activation"
    from "mercury@centerology.com"
    body({:person => person})
  end
  def share_redirect (email, message, permalink)
    recipients email
    subject "VeeJay.tv Share"
    from "mercury@centerology.com"
    body({:email => email, :message => message, :permalink => permalink})
  end
end
