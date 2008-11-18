#

class Mercury < ActionMailer::Base
  delivery_method = :sendmail
  def activation_code (person)
    recipients person.email
    subject "VeeJay.tv Activation"
    from "mercury@centerology.com"
    body :person => person
  end
end
