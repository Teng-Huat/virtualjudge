// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

import bootstrap from "bootstrap"
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

jQuery(document).ready(function(){
  jQuery("#add-problem").click(function(e){ //on add input button click
    e.preventDefault();
    jQuery(".problem-container").append(`
      <div class="form-group">
        <div class="col-md-9">
          <input type="text" class="form-control" name="contest[problems][]" />
        </div>
        <div class="col-md-3">
          <a href="#" class="btn btn-danger remove_field">Remove</a>
        </div>
      </div>
      `); //add input box
  });
  jQuery(".problem-container").on("click",".remove_field", function(e){ //user click on remove text
    e.preventDefault(); jQuery(this).parent('div').parent('div').remove();
  })
});
