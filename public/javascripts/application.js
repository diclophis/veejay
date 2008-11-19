// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var sc;

y_up_eventHandler = function( pType, pItem ) {
  //alert(pType);
  //alert(Object.toJSON(pItem));
  //{"type": "S_AD", "clipid": "v2140336", "spaceId": "396500312"}
  //{"type": "S_AD", "clipid": "v2140336", "spaceId": "396500312"}
  //{"type": "S_STREAM", "clipid": "v2140336", "spaceId": "396500312"}
  switch (pType){
    case "init":            // thrown when the player has been initialized and the flash external API is ready to be accessed
    case "itemBegin":       // thrown when a video starts playing for the first time
      switch(pItem.type) {
        case "S_STREAM":
          $('video_id').value = pItem.clipid.sub('v', '', 1);
          new Ajax.Updater('pop_container', $('pop_form').action, {
            parameters : Form.serialize($('pop_form')),
            onComplete : function () {
            }
          });
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

var videos;

Event.observe(window, 'load', function () {
  $$("#person_nickname").each(function(element) {
    element.focus();
  });
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

    so = new SWFObject('http://d.yimg.com/cosmos.bcst.yahoo.com/up/fop/embedflv/swf/fop.swf', 'uvp_fop', '512', '322', '9', '#ffffff');
    so.addVariable('id', videos.join(','));
    so.addVariable('eID', '1301797');    // NEEDS TO CHANGE DEPENDING ON LOCALE
    so.addVariable('ympsc', '4195351');  // NEEDS TO CHANGE DEPENDING ON LOCALE
    so.addVariable('lang', 'en');        // NEEDS TO CHANGE DEPENDING ON LOCALE
    so.addVariable('shareEnable', '0');
    so.addParam("allowFullScreen", "true");
    so.addVariable('enableFullScreen', '1');
    so.addVariable('autoStart', '1');
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
          $$('form ul#results li').each(function(video_li) {
            new Draggable(video_li.id, {
              scroll: window
            });
          });
        }
      });
    });
    Droppables.add('drop', {
      accept: 'video',
      hoverclass: 'hover',
      onDrop: function(draggable, droppable, dragged) {
        html = draggable.innerHTML;
        draggable.remove();
        droppable.insert(html);
      }
    });
  });

  /*
  $$('form#create').each(function(create_form) {
    Event.observe(create_form, 'submit', function(submitted) {
     
    });
  });
  */


  //Sortable.create('videos', {constraint:null,ghosting:true});
  /*
autoStart   0|1 (default: 0)  Used to auto start the video on player load.
bw  integer   Used to force a bandwidth; if bw is not specified the player will attempt to determine the best video bitrate quality for the user.
eh  string  Callback event handler that the player should make calls to.
lang  string (default: "en")  Language to use w/in player. See Supported Locales for possible values.
closeEnable   0|1 (default: 0)  Sets visibility of the close button; button action will throw a callback event of type "close".
controlsEnable  0|1 (default: 1)  Enables the player controls.
enableFullScreen  0|1 (default: 0)  Displays/hides fullscreen button (requires allowFullScreen param to be set - see embed example above).
infoEnable  0|1 (default: 1)  Sets visibility of the "more info" button.
nowplayingEnable  0|1 (default: 1)  Enables the intro "Now Playing: ..." component during the first few seconds of playback.
postpanelEnable   0|1 (default: 1)  Enables the post panel; displayed after a clip completes playback.
prepanelEnable  0|1 (default: 1)  Enables the pre meta panel on player initialization when autoStart is false and a valid id has been passed into the player.
shareEnable   0|1 (default: 0)  Enables the Share panel.


   */
});
