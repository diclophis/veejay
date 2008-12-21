namespace 'search' do
  desc 'Search Artists'
  task 'artists' => :environment do
    require 'remote_artist'
    artists = RemoteArtist.search("Friendly Fires 'On Board'")
    puts artists.inspect
  end
end
