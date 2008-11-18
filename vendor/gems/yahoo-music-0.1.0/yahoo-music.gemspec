Gem::Specification.new do |s|
  s.name     = "yahoo-music"
  s.version  = "0.1.0"
  s.date     = "2008-11-13"
  s.summary  = "A Ruby wrapper for the Yahoo! Music API."
  s.email    = "mail@matttthompson.com"
  s.homepage = "http://github.com/mattt/yahoo-music/"
  s.description = "A Ruby wrapper for the Yahoo! Music API.
                   See http://developer.yahoo.com/music/ for more information about the API."
  s.authors  = ["Mattt Thompson"]
  
  s.files    = [
		"README", 
		"yahoo-music.gemspec", 
		"lib/yahoo-music.rb",
		"lib/rest.rb",
		"lib/yahoo-music/base.rb",
		"lib/yahoo-music/artist.rb",
		"lib/yahoo-music/category.rb",
		"lib/yahoo-music/release.rb",
		"lib/yahoo-music/review.rb",
		"lib/yahoo-music/track.rb",
		"lib/yahoo-music/video.rb",
		"lib/yahoo-music/version.rb"
	]
  s.test_files = [
    "test/test_helper.rb",
    "test/test_yahoo_music_artist.rb",
    "test/test_yahoo_music_release.rb"
  ]
  
  s.add_dependency("hpricot",       ["> 0.6"])
  s.add_dependency("activesupport", ["> 2.1.0"])
  s.add_dependency("flexmock",      ["> 0.8.2"])
  
  s.has_rdoc = false
  s.rdoc_options = ["--main", "README"]
end