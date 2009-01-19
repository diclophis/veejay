// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var last_video = current_video = 0;
var auto = false;
var videos;
var list;
var youtube_remote_id;

//this attaches the actions to the share buttons for facebook connect users
attach_to_share_episode_buttons = function () {
  $$('a.share_episode_button').each(function(share_episode_button) {
    Event.observe(share_episode_button, 'click', function(clicked) {
      Event.stop(clicked);
      episode_id = this.id.replace("share_episode_", "episode_");
      episode = $(episode_id);
      episode_thumbnail = episode.getElementsBySelector('img.episode_thumbnail').detect(function(episode_detail) {
        return true;
      });
      episode_link = episode.getElementsBySelector('a.episode_url').detect(function(episode_detail) {
        return true;
      });
      episode_videos = episode.getElementsBySelector('span.episode_videos').detect(function(episode_detail) {
        return true;
      });
      episode_duration = episode.getElementsBySelector('li.episode_duration').detect(function(episode_detail) {
        return true;
      });
      episode_description = episode.getElementsBySelector('div.episode_description p').pluck('innerHTML').join();
      profile_link = episode.getElementsBySelector('a.profile_url').detect(function(episode_detail) {
        return true;
      });
      var post_data = {
        "title": episode_link.innerHTML,
        "episode_url": episode_link.href,
        "videos": episode_videos.innerHTML,
        "description": episode_description,
        "duration": episode_duration.innerHTML,
        "profile_url": profile_link.href 
      };
      FB.Connect.showFeedDialog(58089846128, post_data, null, null, FB.FeedStorySize.full, FB.RequireConnect.promptConnect, function (w) {
        //you can do something here when they are finished posting, but you do _not_ get if they posted or not (sorta lame)
      });
    });
  });
};

attach_to_confirmable_buttons = function () {
  $$('.confirm').each(function(confirmable) {
    Event.observe(confirmable, 'click', function(clicked) {
      if (confirm("Are you sure you want to delete this set?")) {
        return true;
      } else {
        Event.stop(clicked);
      }
    });
  });
};

attach_to_preview_video_buttons = function () {
  $$('a.preview_video').each(function(preview_video_button) {
    Event.observe(preview_video_button, 'click', function (clicked) {
      Event.stop(clicked);
      preview_w = window.open(this.href,"video_preview","height=420,width=572,location=no,menubar=no,resizable=no,scrollbars=no,status=yes,toolbar=no", false);
    });
  });
}

attach_to_add_remote_video_buttons = function () {
  $$('a.add_remote_video_button').each(function(add_remote_video_button) {
    Event.observe(add_remote_video_button, 'click', function (clicked) {
      Event.stop(clicked);
      remote_id = "video_" + this.id.replace("add_video_", "");
      remote_video = $(remote_id).remove();
      remote_video.getElementsBySelector('.hidden_unless_added').invoke('toggle');
      attach_to_remove_remote_video_buttons();
      $("drop").insert(remote_video);
      Sortable.destroy('drop');
      Sortable.create('drop',{handle:"handle_remote_video_button", containment: ['results', 'drop'], dropOnEmpty: true, constraint: false});
    });
  });
}

add_remote_video = function(remote_id) {
    remote_video = $(remote_id).remove();
    remote_video.getElementsBySelector('.hidden_unless_added').invoke('toggle');
    attach_to_remove_remote_video_buttons();
    $("drop").insert(remote_video);
    Sortable.destroy('drop');
    Sortable.create('drop',{handle:"handle_remote_video_button", containment: ['results', 'drop'], dropOnEmpty: true, constraint: false});
};

attach_to_parent_add_remote_video_buttons = function () {
  $$('a.parent_add_remote_video_button').each(function(add_remote_video_button) {
    Event.observe(add_remote_video_button, 'click', function (clicked) {
      Event.stop(clicked);
      remote_id = "video_" + this.id.replace("add_video_", "");
      window.opener.add_remote_video(remote_id);
      h4 = new Element('h4');
      h4.update('Added!');
      div = new Element('div', {'class':'bottom_flash success'});
      div.update(h4);
      this.parentNode.insert(div);
      this.remove();
    });
  });
}

attach_to_remove_remote_video_buttons = function () {
  $$('a.remove_remote_video_button').each(function(remove_remote_video_button) {
    Event.observe(remove_remote_video_button, 'click', function (clicked) {
      Event.stop(clicked);
      remote_id = "video_" + this.id.replace("remove_video_", "");
      remote_video = $(remote_id).remove();
      Sortable.destroy('drop');
      Sortable.create('drop',{handle:"handle_remote_video_button",  containment: ['results', 'drop'], dropOnEmpty: true, constraint: false});
    });
  });
}

play_video = function () {
  swfobject.removeSWF("the_player_" + last_video);
  $("player_container").insert('<div id="player"></div>');
  remote_id = videos[current_video];
  $$('li.video').each(function(video_li) {
    video_li.removeClassName('current_video');
  });
  $('video_' + remote_id).addClassName('current_video');
  if ($('pops')) {
    $$('li.pop').invoke('hide');
    $('pop_' + remote_id).show();
  }
  chunks = remote_id.split("-");
  type = chunks[0];
  remote_id = remote_id.replace(type + "-", "");
  var params = {};
  params.allowscriptaccess = "always";
  params.allowfullscreen = 'true';
  var attributes = {};
  attributes.id = "the_player_" + current_video;
  attributes.name = "the_player_" + current_video;
  switch (type) {
    case "yahoo":
      var flashvars = {};
      flashvars.id = 'v' + remote_id;
      flashvars.eID = '1301797';
      flashvars.ympsc = '4195351';
      flashvars.lang = 'en';
      flashvars.shareEnabled = '0';
      flashvars.enableFullScreen = '0';
      flashvars.controlsEnable = '1';
      flashvars.autoStart = (auto) ? '1' : '0';
      flashvars.eh = 'yahoo_event_handler';
      swfobject.embedSWF("http://d.yimg.com/cosmos.bcst.yahoo.com/up/fop/embedflv/swf/fop.swf", "player", "512", "332", "9.0.0", false, flashvars, params, attributes);
    break;
    case "mtv":
      var flashvars = {};
      flashvars.autoPlay = auto ? 'true' : 'false';
      swfobject.embedSWF("http://media.mtvnservices.com/mgid:uma:video:api.mtvnservices.com:" + remote_id, "player", "512", "332", "9.0.0", false, flashvars, params, attributes);
    break;
    case "youtube":
      var flashvars = {};
      youtube_remote_id = remote_id;
      swfobject.embedSWF("http://www.youtube.com/v/" + remote_id + "&enablejsapi=1&playerapiid=" + attributes.id + "&autoplay=" + (auto ? '1' : '0') + "&rel=0", "player", "512", "332", "9.0.0", false, flashvars, params, attributes);
    break;
  }
  last_video = current_video;
  current_video++;
  auto = true;
}

function youtube_state_change (state) {
  //Fired whenever the player's state changes.
  //Possible values are:
  //unstarted (-1), 
  //ended (0), 
  //playing (1), 
  //paused (2), 
  //buffering (3), 
  //video cued (5). 
  //When the SWF is first loaded, it will broadcast an unstarted (-1) event.
  //When the video is cued and ready to play, it will broadcast a video cued event (5).
  if (state == 0) {
    play_video();
  }
}

function youtube_error () {
  alert('youtube error');
}

function onYouTubePlayerReady (player_id) {
  player = swfobject.getObjectById(player_id);
  player.addEventListener("onStateChange", "youtube_state_change");
  player.addEventListener("onError", "youtube_error");
}

mtv_state_change = function (state) {
}

mtv_playhead_update = function () {
}

mtv_media_ended = function () {
  play_video();
}

mtv_read = function () {
}

function mtvnPlayerLoaded (player_id) {
  player = swfobject.getObjectById(player_id);
  player.addEventListener('STATE_CHANGE', 'mtv_state_change');
  player.addEventListener('PLAYHEAD_UPDATE', 'mtv_playhead_update');
  player.addEventListener('MEDIA_ENDED', 'mtv_media_ended');
  player.addEventListener('READY', 'mtv_ready'); 
}

function mtvnSetCoad(adObject) {
  return;
}

yahoo_event_handler = function( pType, pItem ) {
  switch (pType){
    case "init":            // thrown when the player has been initialized and the flash external API is ready to be accessed
    break;
    case "itemBegin":       // thrown when a video starts playing for the first time
      /*
      switch(pItem.type) {
        case "S_STREAM":
          if ($('pop_form')) {
            $('video_id').value = pItem.clipid.sub('v', '', 1);
            new Ajax.Updater('pop_container', $('pop_form').action, {
              parameters : Form.serialize($('pop_form')),
              onComplete : function () {
                $('pause_button').show();
              }
            });
          }
        break;
        default:
          $('pop_container').update();
        break;
      }
      */
    break;
    case "done":            // thrown when all videos have played
      play_video();
    break;
    case "itemEnd":         // thrown when a video has played for its total duration
    case "streamPlay":      // thrown anytime a video begins to play
    case "streamPause":     // thrown when vidPause() is requested and completed
    case "streamStop":      // thrown when playback has stopped for whatever reason (not the same as itemEnd)
    case "streamError":     // thrown when an error occurs with the stream
    case "userClick":       // thrown when a user click on clicks on playback compoents w/i the post panel
    break;
  }
}

function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
  var c = ca[i];
  while (c.charAt(0)==' ') c = c.substring(1,c.length);
  if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
  }
  return null;
}


Event.observe(window, 'load', function () {
  $$("#artist_or_song").each(function(element) {
    element.focus();
  });
  if ($('pause_button')) {
    Event.observe($('pause_button'), 'click', function (pause) {
      Event.stop(pause);
      $('play_button').show();
      $('pause_button').hide();
    });
    $('pause_button').hide();
  }

  if ($('play_button')) {
    Event.observe($('play_button'), 'click', function (play) {
      Event.stop(play);
      $('play_button').hide();
      $('pause_button').show();
    });
    $('play_button').hide();
  }

  if ($('player_container')) {
    $$('li.video a').each(function(link_to_video) {
      Event.observe(link_to_video, 'click', function(clicked) {
        Event.stop(clicked);
        selected_video = this.parentNode.id.replace("video_", "");
        selected_video_index = videos.indexOf(selected_video);
        if (selected_video_index > 0) {
        }
        current_video = selected_video_index;
        play_video();
      });
    });
    videos = $$('.video').collect(function(video) { return video.id.replace("video_", ""); });
    play_video();
  }


  $$('form#search').each(function(search_form) {
    Event.observe(search_form, 'submit', function(submitted) {
      Event.stop(submitted);
      new Ajax.Updater('results_container', search_form.action, {
        parameters : Form.serialize(search_form),
        onComplete : function () {
          attach_to_preview_video_buttons();
          attach_to_add_remote_video_buttons();
          attach_to_remove_remote_video_buttons();
          $('artist_or_song').enable();
          $('search_button').enable();
          $('artist_or_song').removeClassName('spinning');
          Sortable.destroy('drop');
          Sortable.create('drop',{handle:"handle_remote_video_button", containment: ['results', 'drop'], dropOnEmpty: true, constraint: false});
        },
        onFailure : function () {
          alert('an error has occured');
          $('artist_or_song').enable();
          $('search_button').enable();
          $('artist_or_song').removeClassName('spinning');
        }
      });
      $('artist_or_song').disable();
      $('search_button').disable();
      $('artist_or_song').addClassName('spinning');
    });
    attach_to_preview_video_buttons();
    attach_to_remove_remote_video_buttons();
    Sortable.create('drop', {handle:"handle_remote_video_button", containment: ['results', 'drop'], dropOnEmpty:true, constraint:false});
  });

  $$('div.edge').each(function(edge) {
    include = (readCookie(edge.id));
    if (include) {
      edge.update(unescape(include).gsub(/\+/, ' '));
    }
    edge.show();
  });

  if (!readCookie("personal_header")) {
    $$('.stranger_only').each(function(stranger_only) {
      stranger_only.show();
    });
  }

  $$('textarea.copypaste').each(function(copypaste) {
    Event.observe(copypaste, 'focus', function(focused) {
      this.select();
    });
  });
  
  if ($('emails')) {
    list = new FacebookList('emails', 'autocomplete', {
      newValues: true,
      fetchFile: '/dashboard/email_autocompletions'
    });
    Event.observe($('share_form'), 'submit', function(submitted) {
      list.update();
      return true;
    });
  }

  $$('.tabs').each(function(tab_group){  
    new Control.Tabs(tab_group);  
  });  

  attach_to_confirmable_buttons();

  //only start up the facebook stuff if its the login/register page
  if ($("facebook")) {
    FB.ensureInit(function() {
      FB.Facebook.get_sessionState().waitUntilReady(function(session) {
        FB.Facebook.apiClient.users_getInfo([FB.Facebook.apiClient.get_session().uid], ["first_name", "proxied_email", "pic"], function(unifoo, ex){
          //once we get here, we either have an authenticated session with facebook or null
          if (ex == null) {
            if ($('facebook_register_form')) {
              //when its the register form, fill in the user id to the form, and submit it (along with their prompted nickname)
              if ($("uid").value == "") {
                $("facebook_person_nickname").value = prompt("Please enter a nickname (it must be unique!)", unifoo[0].first_name);
                $("uid").value = unifoo[0].uid;
                $("proxied_email").value = unifoo[0].proxied_email;
                $("facebook_register_form").submit();
              }
            } else {
              window.location.reload();
            }
          } else {
            throw("Exception :" + ex);
          }
        });
      });
    });
  } 

  //when you logout of our site, we need to tell facebook
  $$("a.logout_link").each(function(logout_link) {
    Event.observe(logout_link, 'click', function(clicked) {
      Event.stop(clicked);
      href = this.href;
      FB.Connect.logout(function(logged_out) {
        //this happens whether or not the person was logged in
        window.location = href;
      });
    });
  });

  attach_to_parent_add_remote_video_buttons();
  attach_to_share_episode_buttons()

});
