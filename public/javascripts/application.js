// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var last_video = current_video = 0;
var videos;
var list;
var youtube_remote_id;

push_to_facebook = function () {
//626675667
//57768276128
//FB.FeedStorySize.oneLine
//FB.RequireConnect.promptConnect
//var comment_data = {"verb":'commented on the video ', "noun":'Sample Video', "body":'Here is text for the sample body.', "fullbody":'Here is the sample body text for a full story.', "images":[{'src':'http://www.somethingtoputhere.com/therunaround/images/runaround_image.jpg', 'href':'http://www.facebook.com'}]};
  var post_data = {"title":"wang chung"};
  FB.Connect.showFeedDialog(57768276128, post_data, null, null, FB.FeedStorySize.oneLine, FB.RequireConnect.promptConnect, function (w) {
    //alert(w);
    //alert('done');
  }); 
}

on_facebook_register = function () {
  alert('wangchung');
};

attach_to_confirmable_buttons = function () {
  $$('.confirm').each(function(confirmable) {
    Event.observe(confirmable, 'click', function(clicked) {
      if (confirm("Are you sure?")) {
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
      window.open(this.href,"video_preview","height=420,width=572,location=no,menubar=no,resizable=no,scrollbars=no,status=yes,toolbar=no", false);
    });
  });
}

attach_to_add_remote_video_buttons = function () {
  $$('a.add_remote_video_button').each(function(add_remote_video_button) {
    Event.observe(add_remote_video_button, 'click', function (clicked) {
      Event.stop(clicked);
      remote_id = "video_" + this.id.replace("add_video_", "");
      remote_video = $(remote_id).remove();
      remote_video.getElementsBySelector('a.add_remote_video_button').invoke('toggle');
      remote_video.getElementsBySelector('a.remove_remote_video_button').invoke('toggle');
      remote_video.getElementsBySelector('a.handle_remote_video_button').invoke('toggle');
      attach_to_remove_remote_video_buttons();
      $("drop").insert(remote_video);
      remote_video.getElementsBySelector('ul.tabs').each(function(tabs) {
        tabs.toggle();
        new Control.Tabs(tabs);  
      });
      Sortable.destroy('drop');
      Sortable.create('drop',{handle:"handle_remote_video_button", containment: ['results', 'drop'], dropOnEmpty: true, constraint: false});
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
      flashvars.autoStart = '1';
      flashvars.eh = 'yahoo_event_handler';
      swfobject.embedSWF("http://d.yimg.com/cosmos.bcst.yahoo.com/up/fop/embedflv/swf/fop.swf", "player", "512", "332", "9.0.0", false, flashvars, params, attributes);
    break;
    case "mtv":
      var flashvars = {};
      flashvars.autoPlay = 'true';
      swfobject.embedSWF("http://media.mtvnservices.com/mgid:uma:video:api.mtvnservices.com:" + remote_id, "player", "512", "332", "9.0.0", false, flashvars, params, attributes);
    break;
    case "youtube":
      var flashvars = {};
      youtube_remote_id = remote_id;
      swfobject.embedSWF("http://www.youtube.com/v/" + remote_id + "&enablejsapi=1&playerapiid=" + attributes.id + "&autoplay=1&rel=0", "player", "512", "332", "9.0.0", false, flashvars, params, attributes);
      //alert("http://www.youtube.com/v/" + remote_id + "&enablejsapi=1&playerapiid=" + attributes.id + "&autoplay=1&rel=0");
      //alert("http://www.youtube.com/v/" + remote_id + "&enablejsapi=1&playerapiid=the_player&autoplay=1&rel=0");
      //swfobject.embedSWF("http://www.youtube.com/apiplayer?enablejsapi=1&playerapiid=" + attributes.id + "&rel=0", "player", "512", "332", "9.0.0", false, flashvars, params, attributes);
    break;
  }
  last_video = current_video;
  current_video++;
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
  /*
  player.loadVideoById(youtube_remote_id, 0);
  */
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
  //$$("#person_nickname").each(function(element) {
  //  element.focus();
  //});
  $$("#artist_or_song").each(function(element) {
    element.focus();
  });
  if ($('pause_button')) {
    Event.observe($('pause_button'), 'click', function (pause) {
      Event.stop(pause);
      /*
      $('uvp_fop').vidPause();
      */
      $('play_button').show();
      $('pause_button').hide();
    });
    $('pause_button').hide();
  }

  if ($('play_button')) {
    Event.observe($('play_button'), 'click', function (play) {
      Event.stop(play);
      /*
      $('uvp_fop').vidPlay();
      */
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
          //left_side = videos.slice(0, selected_video_index - 1);
          //right_side = videos.slice(selected_video_index);
          //videos = $A(right_side.concat(left_side)).join(",");
        }
        //$('uvp_fop').playID(videos);
        current_video = selected_video_index;
        play_video();
      });
    });
    videos = $$('.video').collect(function(video) { return video.id.replace("video_", ""); });
    play_video();
  }
  /*
  if ($('uvp_fop_container')) {
    videos = $$('li.video').collect(function(video) { return 'v' + video.id.replace("video_", ""); });
    $$('li.video a').each(function(link_to_video) {
      Event.observe(link_to_video, 'click', function(clicked) {
        Event.stop(clicked);
        selected_video = "v" + this.parentNode.id.replace("video_", "");
        selected_video_index = videos.indexOf(selected_video);
        if (selected_video_index > 0) {
          left_side = videos.slice(0, selected_video_index - 1);
          right_side = videos.slice(selected_video_index);
          videos = $A(right_side.concat(left_side)).join(",");
        }
        $('uvp_fop').playID(videos);
      });
    });
    so = new SWFObject('http://d.yimg.com/cosmos.bcst.yahoo.com/up/fop/embedflv/swf/fop.swf', 'uvp_fop', '580', '322', '9', '#ffffff');
    so.addVariable('id', videos.join(','));
    so.addVariable('eID', '1301797');    // NEEDS TO CHANGE DEPENDING ON LOCALE
    so.addVariable('ympsc', '4195351');  // NEEDS TO CHANGE DEPENDING ON LOCALE
    so.addVariable('lang', 'en');        // NEEDS TO CHANGE DEPENDING ON LOCALE
    so.addVariable('shareEnable', '0');
    so.addParam("allowFullScreen", "true");
    so.addVariable('enableFullScreen', '1');
    so.addVariable('autoStart', '0');
    so.addVariable('controlsEnable', '0');
    so.addVariable('eh', 'y_up_eventHandler');
    so.addParam("allowScriptAccess", "always");  // for scripting access
    so.write('uvp_fop_container');
  }
  */

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
          //Sortable.destroy('results');
          //Sortable.create('results',{containment: ['results', 'drop'], dropOnEmpty: true, constraint: false, revert: false, scroll: window});
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

  //DD_roundies.addRule("ul.tabs li", 10);
  //DD_roundies.addRule("ul.tabs li.tab a", 10);

  DD_roundies.addRule("#header", 10);
  DD_roundies.addRule("#sidebar", 10);
  DD_roundies.addRule("#content", 10);

  if ($("facebook")) {
    FB.ensureInit(function() {
      FB.Facebook.get_sessionState().waitUntilReady(function(session) {
        alert('wtf');
        //var is_now_logged_into_facebook = session ? true : false;
        // if the new state is the same as the old (i.e., nothing changed)
        // then do nothing
        //if (is_now_logged_into_facebook == already_logged_into_facebook) {
        //  return;
        //}
    //// otherwise, refresh to pick up the state change
    //refresh_page();
      });
    });
  } 
});
