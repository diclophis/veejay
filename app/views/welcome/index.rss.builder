xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "all sets"
    xml.description "all sets"
    xml.link(root_url)
    @recent_episodes.each { |episode|
      xml.item do
        xml.title(episode.title)
        xml.description(link_to(content_tag(:p, episode.description) + image_tag(episode.videos.first.remote_video.image_url), episode_url(*episode.to_param)))
        xml.pubDate(episode.created_at.to_s(:rfc822))
        xml.link(episode_url(*episode.to_param))
      end
    }
  end
end

