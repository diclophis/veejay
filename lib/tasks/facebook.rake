namespace 'facebook' do
  desc 'Fix'
  task 'fix' => :environment do
    j = Person.find_by_nickname("jon5")
    j.facebook_user_id = ""
    j.identity_url = "http://diclophis.pip.verisignlabs.com"
    j.save!
  end
end
