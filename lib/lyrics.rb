#

class Lyrics
  include Singleton
  attr_accessor :driver 
  def initialize
    self.driver = SOAP::WSDLDriverFactory.new("http://lyricwiki.org/server.php?wsdl").create_rpc_driver 
  end
  def self.for(artist, song)
    lyrics = self.instance.driver.getSong(artist, song).lyrics
    if lyrics == "Not found" then
      nil
    else
      lyrics
    end
  end
end
