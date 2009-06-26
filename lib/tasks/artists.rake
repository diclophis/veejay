namespace 'search' do
  desc 'Search Artists'
  task 'artists' => :environment do
    require 'remote_artist'
    artists = RemoteArtist.search("Friendly Fires 'On Board'")
    puts artists.inspect
  end
  desc 'Spam'
  task 'spam' => :environment do
    Person.find(:all).each { |person|
      puts person.email
    }
  end
end
