// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var sc;

y_up_eventHandler = function( pType, pItem ) {
  //{"type": "S_AD", "clipid": "v2140336", "spaceId": "396500312"}
  //{"type": "S_AD", "clipid": "v2140336", "spaceId": "396500312"}
  //{"type": "S_STREAM", "clipid": "v2140336", "spaceId": "396500312"}
  switch (pType){
    case "init":            // thrown when the player has been initialized and the flash external API is ready to be accessed
    case "itemBegin":       // thrown when a video starts playing for the first time
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
    break;
    case "itemEnd":         // thrown when a video has played for its total duration
    case "done":            // thrown when all videos have played
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

var videos;

Event.observe(window, 'load', function () {
  $$("#person_nickname").each(function(element) {
    element.focus();
  });
  if ($('pause_button')) {
    Event.observe($('pause_button'), 'click', function (pause) {
      Event.stop(pause);
      $('uvp_fop').vidPause();
      $('play_button').show();
      $('pause_button').hide();
    });
    $('pause_button').hide();
  }

  if ($('play_button')) {
    Event.observe($('play_button'), 'click', function (play) {
      Event.stop(play);
      //$('uvp_fop').setVidHeight("1000");
      $('uvp_fop').vidPlay();
      $('play_button').hide();
      $('pause_button').show();
    });
    $('play_button').hide();
  }

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

  $$('form#search').each(function(search_form) {
    Event.observe(search_form, 'submit', function(submitted) {
      Event.stop(submitted);
      new Ajax.Updater('results_container', search_form.action, {
        parameters : Form.serialize(search_form),
        onComplete : function () {
          $('artist_or_song').enable();
          $('search_button').enable();
          $('artist_or_song').removeClassName('spinning');
          Sortable.destroy('results');
          Sortable.destroy('drop');
          Sortable.create('results',{containment: ['results', 'drop'], dropOnEmpty: true, constraint: false, revert: false, scroll: window});
          Sortable.create('drop',{containment: ['results', 'drop'], dropOnEmpty: true, constraint: false});
        }
      });
      $('artist_or_song').disable();
      $('search_button').disable();
      $('artist_or_song').addClassName('spinning');
    });
    Sortable.create('drop',{containment: ['results', 'drop'], dropOnEmpty:true, constraint:false});
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
      fetchFile: '/emails.json'
    });
  }
});
