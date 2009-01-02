#
class RemoteRelease
  #include Comparable
  attr_accessor :remote_id, :title, :release_year, :release_date, :label, :upc
  def initialize(remote_id, title, release_year, release_date, label, upc)
    self.remote_id = remote_id
    self.title = title
    self.release_year = release_year
    self.release_date = release_date
    self.label = label
    self.upc = upc
  end
  def eql?(other_remote_release)
    if other_remote_release.instance_of?(self.class)then
      if self.upc == other_remote_release.upc then
        return true
      else
        left_tokens = self.title.split(" ")
        right_tokens = other_remote_release.title.split(" ")
        last_left_tokens = left_tokens.slice(-2, 1)
        last_right_tokens = right_tokens.slice(-2, 1)
        if last_left_tokens and last_right_tokens then
          return last_left_tokens.join == last_right_tokens.join
        else
          return self.title == other_remote_release.title
        end
      end
    else
      return super(other_remote_release)
    end
  end
  def hash
    self.title.hash
  end
end

class RemoteArtist
  attr_accessor :remote_id, :name, :website, :releases

  def initialize (remote_id, name, website, releases)
    self.remote_id = remote_id
    self.name = name
    self.website = website
    self.releases = releases
  end

  def self.fetch (format, artist_or_song)
    begin
      encoded_artist_or_song = URI.encode(artist_or_song)
      url = format % [encoded_artist_or_song]
      Timeout::timeout(1) do
        data = Fast.fetch(url)
      end
    rescue Exception => problem
      nil
    end
  end

  def self.extract_yahoo_artists (data)
    begin
      xml = Hpricot::XML(data)
      xml.search("Artist").collect { |artist|
        releases = artist.search("Releases/Release").collect { |release|
          RemoteRelease.new(
            release.attributes["id"],
            release.attributes["title"],
            release.attributes["releaseYear"],
            release.attributes["releaseDate"],
            release.attributes["label"],
            release.attributes["UPC"]
          )
        }.delete_if { |release|
          release.upc.blank?
        }.uniq
        RemoteArtist.new(
          artist.attributes["id"],
          artist.attributes["name"],
          artist.attributes["website"],
          releases
        )
      }
    rescue => problem
    #raise problem
      []
    end
  end
  def self.search(artist, limit = nil, offset = nil)
    yahoo_format = "http://us.music.yahooapis.com/artist/v1/list/search/all/%s?response=releases&appid=lbQe24DV34HOfBA1dKUdCW_UVvWU2mUjGlXI1yO_RRKiczchv2K5YyrvCcs6Bk_x"
    yahoo_data = self.fetch(yahoo_format, artist)
    #raise yahoo_data.inspect
    return self.extract_yahoo_artists(yahoo_data)
  end
end

=begin
releases,toptracks,topsimilar,events,videos

{elem <Artist hotzillaID="1800332692" flags="65535" rating="-1" name="Beck" catzillaID="1927034532" trackCount="174" website="http://www.beck.com/" id="262397" salesGenreCode="38"> {elem <ItemInfo> {emptyelem <Relevancy index="6819">} </ItemInfo>} </Artist>} {elem <Artist hotzillaID="1800115540" flags="65535" rating="-1" name="Jeff Beck" catzillaID="1927003075" trackCount="275" website="http://www.jeffbeck.com/" id="262418"> {elem <ItemInfo> {emptyelem <Relevancy index="816">} </ItemInfo>} </Artist>} {elem <Artist hotzillaID="1801924968" flags="37263" rating="-1" name="Joe Beck" catzillaID="1927005239" trackCount="20" id="262429"> {elem <ItemInfo> {emptyelem <Relevancy index="707">} </ItemInfo>} </Artist>}

=end
