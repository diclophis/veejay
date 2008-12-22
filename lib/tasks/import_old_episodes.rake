namespace 'db' do
  desc 'Import Old Episodes'
  task 'import_old_episodes' => :environment do
    require 'remote_artist'
    old_episodes = ActiveSupport::JSON.decode(File.open("/var/www/veejay/old_episodes.json").readlines.join)
    old_episodes.each { |old_episode|
      if Person.exists?(old_episode[1]["episode"]["person_id"]) then
        new_episode = Episode.new
        new_episode.total_duration = 0
        begin
          Person.transaction do
            old_episode[0].each { |old_video|
              found_remote_videos = RemoteVideo.find_by_id(old_video["video"]["yahoo_id"])
              if found_remote_videos.length == 1 then
                remote_video = found_remote_videos[0]
                new_episode.videos << Video.create({
                  :comment => "",
                  :remote_video => remote_video
                })
                new_episode.total_duration += remote_video.duration
              end
            }
            new_episode.title = old_episode[1]["episode"]["title"] 
            new_episode.description = old_episode[1]["episode"]["description"] 
            new_episode.person_id = old_episode[1]["episode"]["person_id"] 
            new_episode.save!
          end
        rescue => problem
          puts problem.inspect
          puts new_episode.inspect
        end
      end
    }
  end
end
