#

#"wang %d chung %d" % [1, 2]
=begin
  remote_video_id
  remote_video_image_url
  remote_video_title
  remote_video_artist_names
  remote_video_duration
=end

class RemoteVideo
  attr_accessor :remote_id, :image_url, :title, :artist_names, :duration

  #def to_json (options = {})
  #  ActiveSupport::JSON.encode(instance_values, options)
  #end

  def initialize (remote_id, title, duration, artist_names, image_url)
    self.remote_id = remote_id
    begin
      URI.parse(image_url)
      self.image_url = image_url
    rescue
      self.image_url = "/images/bluebox.jpg"
    end
    self.title = title
    self.artist_names = artist_names
    self.duration = duration.to_i
  end

  def formatted_duration
    seconds = self.duration
    return "" if seconds == 0
    m = (seconds/60).floor
    s = (seconds - (m * 60)).round
# add leading zero to one-digit minute
    if m < 10 then
      m = "0#{m}"
    end
# add leading zero to one-digit second
    if s < 10 then
      s = "0#{s}"
    end
# return formatted time
    return "#{m}:#{s}"
  end
  
  def self.find_by_id (remote_video_id)
    yahoo_format = "http://us.music.yahooapis.com/video/v1/item/%s?appid=lbQe24DV34HOfBA1dKUdCW_UVvWU2mUjGlXI1yO_RRKiczchv2K5YyrvCcs6Bk_x"
    yahoo_data = self.fetch(yahoo_format, remote_video_id)
    yahoo_videos = self.extract_yahoo_videos(yahoo_data)
  end

  def self.fetch (format, artist_or_song)
    begin
      Timeout::timeout(3) do
        encoded_artist_or_song = URI.encode(artist_or_song)
        url = format % [encoded_artist_or_song]
        data = Fast.fetch(url)
      end
    rescue Exception => problem
      nil
    end
  end

  def self.extract_youtube_videos (data)
    begin
      xml = Hpricot::XML(data)
      xml.search("item").collect { |video|
        title = video.title
        remote_id = video.search("guid").collect { |guid|
          "youtube-" + guid.to_plain_text.split(":").last
        }.first
        video.search("yt:noembed").collect { |crap|
          remote_id = ""
        }
        duration = video.search("yt:duration").collect { |yt_duration|
          yt_duration.attributes["seconds"]
        }.first
        artist_names = []
        image_url = video.search("media:thumbnail").sort_by { |image|
          image.attributes["width"].to_i
        }.collect { |image|
          image.attributes["url"]
        }.last
        RemoteVideo.new(remote_id, title, duration, artist_names, image_url)
      }.delete_if { |video|
        video.remote_id.blank? or video.remote_id == 0
      }
    rescue
      []
    end
  end

  def self.extract_mtv_videos (data)
    begin
      xml = Hpricot::XML(data)
      xml.search("item").collect { |video|
        title = video.title
        remote_id, duration = video.search("media:content").collect { |media_content|
          ["mtv-" + media_content.attributes["url"].split(":").last, media_content.attributes["duration"]]
        }.first
        artist_names = video.search("media:credit").delete_if { |credit|
          credit.attributes["role"] != "artist/performer"
        }.collect { |credit|
          credit.to_plain_text
        }
        image_url = video.search("media:thumbnail").sort_by { |image|
          image.attributes["width"].to_i
        }.collect { |image|
          image.attributes["url"]
        }.last
        RemoteVideo.new(remote_id, title, duration, artist_names, image_url)
      }.delete_if { |video|
        video.remote_id.blank? or video.remote_id == 0
      }
    rescue
      []
    end
  end
  def self.extract_yahoo_videos (data)
    begin
      xml = Hpricot::XML(data)
      xml.search("Video").collect { |video|
        title = video.attributes["title"]
        remote_id = video.attributes["id"]
        unless remote_id.nil?
          remote_id = "yahoo-" + remote_id
        end
        duration = video.attributes["duration"]
        artist_names = video.search("Artist").collect { |artist|
          artist.attributes["name"]
        }
        image_url = video.search("Image").collect { |image|
          image.attributes["url"]
        }.first
        RemoteVideo.new(remote_id, title, duration, artist_names, image_url)
      }.delete_if { |video|
        video.remote_id.blank? or video.remote_id == 0
      }
    rescue
      []
    end
  end
  def self.search(artist_or_song, limit = nil, offset = nil)
    yahoo_format = "http://us.music.yahooapis.com/video/v1/list/search/all/%s?appid=lbQe24DV34HOfBA1dKUdCW_UVvWU2mUjGlXI1yO_RRKiczchv2K5YyrvCcs6Bk_x"
    yahoo_data = self.fetch(yahoo_format, artist_or_song)
    yahoo_videos = self.extract_yahoo_videos(yahoo_data)
    mtv_format = "http://api.mtvnservices.com/1/video/search/?term=%s&feed-format=mrss"
    mtv_data = self.fetch(mtv_format, artist_or_song)
    mtv_videos = self.extract_mtv_videos(mtv_data)
#orderby=viewCount
    youtube_format = "http://gdata.youtube.com/feeds/api/videos?q=%s&alt=rss&v=2"
    youtube_data = self.fetch(youtube_format, artist_or_song)
    youtube_videos = self.extract_youtube_videos(youtube_data)
    good_videos = (yahoo_videos + mtv_videos).sort_by { |video|
      video.title
    }
    (good_videos + youtube_videos)
  end
end

=begin
<Video flags="1" rating="-1" localOnly="0" title="Nothing Really Matters [Video]" typeID="1" rights="1" id="157421337" copyrightYear="2006" label="Warner Bros." duration="269" explicit="0"><Image size="385" url="http://d.yimg.com/img.music.yahoo.com/image/v1/video/157421337?size=385"></Image><Artist hotzillaID="1800038606" flags="65535" rating="-1" name="Madonna" catzillaID="1927049533" trackCount="374" website="http://www.madonna.com/" id="256352" salesGenreCode="3"></Artist><Category rating="-1" name="Pop" type="Genre" id="7318647"></Category></Video>
=end

=begin
<item>
  <title>She's Madonna - Robbie Williams</title>
  <link>http://pa.yahoo.com/*http://US.rd.yahoo.com/launch/ms/RSSfeeds/ymulink/evt=37895/*http://music.yahoo.com/video/39720711?fs=1</link>
  <description>(C) 2007 EMI.</description>
  <pubDate>Thu, 04 Dec 2008 09:50:44 PST</pubDate>
  <content:encoded>
  </content:encoded>
  <media:content medium="video">
    <media:player height="690" width="520" url="http://US.rd.yahoo.com/launch/ms/RSSfeeds/ymulink/evt=37894/*http://music.yahoo.com/video/39720711?fs=1"/>
  </media:content>
  <media:credit role="artist" cf:name="credit">Robbie Williams</media:credit>
  <media:title type="plain" cf:name="title"></media:title>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/003/497/3497632.jpg" height="40" width="40"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/003/497/3497633.jpg" height="80" width="80"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/028/467/28467354.jpg" height="110" width="110"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/003/497/3497630.jpg" height="135" width="135"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/028/467/28467356.jpg" height="190" width="190"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/028/467/28467355.jpg" height="300" width="300"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/noPicture55.jpg" height="55" width="55"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/014/276/14276395.jpg" height="65" width="65"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/038/240/38240624.jpg" height="206" width="206"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/038/240/38240623.jpg" height="160" width="160"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/038/240/38240622.jpg" height="145" width="145"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/038/240/38240621.jpg" height="120" width="120"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/038/240/38240620.jpg" height="83" width="83"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/000/205/739/205739470.jpg" height="200" width="200"/>
  <media:thumbnail url="http://d.yimg.com/img.music.yahoo.com/noPicture75.jpg" height="75" width="75"/>
  <ymusic:asset type="artist">
    <ymusic:link>http://US.rd.yahoo.com/launch/ms/RSSfeeds/ymulink/evt=37894/*http://music.yahoo.com/ar-291668</ymusic:link>
  </ymusic:asset>
  <ymusic:asset type="Video">
    <ymusic:link>http://US.rd.yahoo.com/launch/ms/RSSfeeds/ymulink/evt=37894/*http://music.yahoo.com/ar-291668</ymusic:link>
  </ymusic:asset>
</item>

bad:          <media:player height="690" width="520" url="http://US.rd.yahoo.com/launch/ms/RSSfeeds/ymulink/evt=37894/*http://music.yahoo.com/video/?fs=1"/>
good:           <media:player height="690" width="520" url="http://US.rd.yahoo.com/launch/ms/RSSfeeds/ymulink/evt=37894/*http://music.yahoo.com/video/39720711?fs=1"/>

<item>
  <title>Borderline</title>
  <guid>http://api.mtvnservices.com/1/video/hznHivqrbHHXXAPA/</guid>
  <pubDate>Sat, 1 Jan 1983 00:00:00 GMT</pubDate>
  <description>Madonna | Borderline | Warner Bros. Records</description>
  <atom:link rel="self" type="application/atom+xml" href="http://api.mtvnservices.com/1/video/hznHivqrbHHXXAPA/"/>
  <atom:link rel="http://api.mtvnservices.com/1/schemas/artist" type="application/atom+xml" href="http://api.mtvnservices.com/1/artist/madonna/"/>
  <atom:link rel="http://api.mtvnservices.com/1/schemas/genre" type="application/atom+xml" title="Pop" href="http://api.mtvnservices.com/1/genre/pop/"/>
  <media:content url="http://media.mtvnservices.com/mgid:uma:video:api.mtvnservices.com:33474" duration="237" type="application/x-shockwave-flash" medium="video" isDefault="true" expression="full"/>
  <media:player url="http://www.mtv.com/overdrive/?vid=33474"/>
  <media:title>Borderline</media:title>
  <media:description>Madonna | Borderline | Warner Bros. Records</media:description>
  <media:thumbnail url="http://www.mtv.com/bands/m/madonna/thumbnails/borderline_70x53.jpg" height="53" width="70"/>
  <media:thumbnail url="http://www.mtv.com/bands/m/madonna/thumbnails/borderline_82x55.jpg" height="55" width="82"/>
  <media:thumbnail url="http://www.vh1.com/sitewide/promoimages/artists/m/madonna/vspot/borderline/84x77.jpg" height="77" width="84"/>
  <media:thumbnail url="http://www.mtv.com/bands/m/madonna/thumbnails/borderline_140x105.jpg" height="105" width="140"/>
  <media:thumbnail url="http://www.vh1.com/sitewide/promoimages/artists/m/madonna/vspot/borderline/320x240.jpg" height="240" width="320"/>
  <media:restriction type="country" relationship="allow">US </media:restriction>
  <media:keywords><![CDATA[Madonna, Borderline]]></media:keywords>
  <media:credit role="director" scheme="urn:ebu"/>
  <media:credit role="artist/performer" scheme="urn:ebu">Madonna</media:credit>
  <media:category scheme="urn:mtvn:governing_agreement" label="Governing Agreement">1</media:category>
</item>

<?xml version='1.0' encoding='UTF-8'?><rss xmlns:atom='http://www.w3.org/2005/Atom' xmlns:openSearch='http://a9.com/-/spec/opensearch/1.1/' xmlns:gml='http://www.opengis.net/gml' xmlns:georss='http://www.georss.org/georss' xmlns:media='http://search.yahoo.com/mrss/' xmlns:batch='http://schemas.google.com/gdata/batch' xmlns:yt='http://gdata.youtube.com/schemas/2007' xmlns:gd='http://schemas.google.com/g/2005' version='2.0'><channel><atom:id>tag:youtube.com,2008:videos</atom:id><lastBuildDate>Thu, 04 Dec 2008 22:28:58 +0000</lastBuildDate><category domain='http://schemas.google.com/g/2005#kind'>http://gdata.youtube.com/schemas/2007#video</category><title>YouTube Videos matching query: madonna</title><description/><link>http://www.youtube.com</link><image><url>http://www.youtube.com/img/pic_youtubelogo_123x63.gif</url><title>YouTube Videos matching query: madonna</title><link>http://www.youtube.com</link></image><managingEditor>YouTube</managingEditor><generator>YouTube data API</generator><openSearch:totalResults>119956</openSearch:totalResults><openSearch:startIndex>1</openSearch:startIndex><openSearch:itemsPerPage>25</openSearch:itemsPerPage>


<item>
  <guid isPermaLink='false'>tag:youtube.com,2008:video:wfXFqwN5xYc</guid>
  <pubDate>Tue, 02 Dec 2008 02:54:29 +0000</pubDate>
  <atom:updated>2008-12-04T22:28:58.000Z</atom:updated>
  <title>Britney Spears: For the Record (The Madonna Interview) HQ</title>
  <link>http://www.youtube.com/watch?v=wfXFqwN5xYc</link><author>absolumentmadonna</author>
  <media:group>
    <media:title type='plain'>Britney Spears: For the Record (The Madonna Interview) HQ</media:title>
    <media:description type='plain'>Download in HQ @ http://www.absolumentmadonna.fr/</media:description>
    <media:keywords>
      49, absolument, Angeles, appearance, behind, Britney, Circus, day, Dodger, For, full, HQ, Human, Live, Los, Madonna, Nature, Record, scenes, Spears, Stadium, Sticky, surprise, Sweet, the, Tour, Womanizer
    </media:keywords>
    <yt:duration seconds='286'/>
    <yt:videoid>wfXFqwN5xYc</yt:videoid>
    <yt:uploaded>2008-12-02T02:54:29.000Z</yt:uploaded>
    <media:player url='http://www.youtube.com/watch?v=wfXFqwN5xYc'/>
    <media:credit role='uploader' scheme='urn:youtube'>absolumentmadonna</media:credit>
    <media:category label='Music' scheme='http://gdata.youtube.com/schemas/2007/categories.cat'>Music</media:category>
    <media:content url='http://www.youtube.com/v/wfXFqwN5xYc&amp;f=gdata_videos' type='application/x-shockwave-flash' medium='video' isDefault='true' expression='full' duration='286' yt:format='5'/>
    <media:content url='rtsp://rtsp2.youtube.com/CigLENy73wIaHwmHxXkDq8X1wRMYDSANFEgGUgxnZGF0YV92aWRlb3MM/0/0/0/video.3gp' type='video/3gpp' medium='video' expression='full' duration='286' yt:format='1'/>
    <media:content url='rtsp://rtsp2.youtube.com/CigLENy73wIaHwmHxXkDq8X1wRMYESARFEgGUgxnZGF0YV92aWRlb3MM/0/0/0/video.3gp' type='video/3gpp' medium='video' expression='full' duration='286' yt:format='6'/>
    <media:thumbnail url='http://i.ytimg.com/vi/wfXFqwN5xYc/2.jpg' height='97' width='130' time='00:02:23'/>
    <media:thumbnail url='http://i.ytimg.com/vi/wfXFqwN5xYc/1.jpg' height='97' width='130' time='00:01:11.500'/>
    <media:thumbnail url='http://i.ytimg.com/vi/wfXFqwN5xYc/3.jpg' height='97' width='130' time='00:03:34.500'/>
    <media:thumbnail url='http://i.ytimg.com/vi/wfXFqwN5xYc/0.jpg' height='240' width='320' time='00:02:23'/>
    <media:thumbnail url='http://i.ytimg.com/vi/wfXFqwN5xYc/hqdefault.jpg' height='360' width='480'/>
  </media:group>
  <yt:statistics viewCount='25189' favoriteCount='84'/>
  <gd:rating min='1' max='5' numRaters='64' average='4.75'/>
  <gd:comments>
    <gd:feedLink href='http://gdata.youtube.com/feeds/api/videos/wfXFqwN5xYc/comments?v=2' countHint='81'/>
  </gd:comments>
</item>
=end
