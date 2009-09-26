#

class Lyrics
  #KEY = "d406082d09a06db68-temporary.API.access"
  KEY = "b14851dad4030d0e3-temporary.API.access"
  include Singleton
  attr_accessor :driver 
  def initialize
    #self.driver = SOAP::WSDLDriverFactory.new("http://lyricwiki.org/server.php?wsdl").create_rpc_driver 
    self.driver = SOAP::WSDLDriverFactory.new("http://api.chartlyrics.com/apiv1.asmx?WSDL").create_rpc_driver 
  end
  def self.for(artist, song)
    return nil
    begin
      Timeout::timeout(2.0) do
        if true
          encoded_artist = URI.encode(artist) #.gsub("/[^a-z0-9\\)\\(\\$\\^\\*\\=\\:\\;\\,\\|\\#\\@\\}\\{\\]\\[\\!\\040\\.\\-\\_\\\\]/i", "%")
          encoded_song = URI.encode(song) #.gsub("/[^a-z0-9\\)\\(\\$\\^\\*\\=\\:\\;\\,\\|\\#\\@\\}\\{\\]\\[\\!\\040\\.\\-\\_\\\\]/i", "%")
          url = "http://lyricsfly.com/api/api.php?i=%s&a=%s&t=%s" % [KEY, encoded_artist, encoded_song]
          ActiveRecord::Base.logger.fatal(url)
          data = Fast.fetch(url)
          ActiveRecord::Base.logger.fatal(data)
          if data then
            xml = Hpricot::XML(data)
            return xml.search("tx").collect { |tx|
              tx.to_plain_text.gsub("[br]", "\n")
            }.first
          else
            nil
          end
        end
        if false
          a = self.instance.driver.SearchLyric({:artist => artist, :song => song})
          ActiveRecord::Base.logger.fatal("\n\n\nA\n")
          ActiveRecord::Base.logger.fatal(a.inspect)
          ActiveRecord::Base.logger.fatal("\n\n\n\n")
          if a.searchLyricResult.searchLyricResult.is_a?(Array) then
            b = a.searchLyricResult.searchLyricResult.first
          else
            b = a.searchLyricResult.searchLyricResult
          end
          ActiveRecord::Base.logger.fatal("\n\n\nB\n")
          ActiveRecord::Base.logger.fatal(b.inspect)
          ActiveRecord::Base.logger.fatal("\n\n\n\n")
          c = self.instance.driver.GetLyric({
            :lyricId => b.lyricId,
            :lyricCheckSum => b.lyricChecksum
          })
          ActiveRecord::Base.logger.fatal("\n\n\nC\n")
          ActiveRecord::Base.logger.fatal(b.inspect)
          ActiveRecord::Base.logger.fatal("\n\n\n\n")
          c.getLyricResult.lyric
        end
        if false
          lyrics = self.instance.driver.getSong(artist, song).lyrics
          if lyrics == "Not found" then
            nil
          else
            lyrics
          end
        end
        nil
      end
    rescue Exception => problem
      ActiveRecord::Base.logger.fatal(problem.inspect)
      ActiveRecord::Base.logger.fatal(problem.backtrace.join("\n"))
      nil
    end
  end
end

