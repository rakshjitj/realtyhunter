function doSearch(event) {
  $.ajax({
    url: "<%= filter_landlords_path %>",
    data: {
      filter: $('#filter').val(),
      active_only: $('#checkbox_active').prop('checked')
    },
    dataType: "script"
  }).fail(function() {
    //console.log("[FAILED] search update failed");
  });
};

// search as user types
var timer;
function throttledSearch() {
  clearInterval(timer);  //clear any interval on key up
  timer = setTimeout(doSearch, 500);
};

// change enter key to tab
function preventEnter(event) {
  if (event.keyCode == 13) {
    $('#checkbox_active').focus();
    return false;
  }
};

function initialize() {
  var bldg_address = $('#map_canvas').attr('data-address') ? $('#map_canvas').attr('data-address') : 'New York, NY, USA';

  $(".autocomplete-input").geocomplete({
    map: "#map_canvas",
    location: bldg_address,
    details: ".details"
  }).bind("geocode:result", function(event, result){
    if (this.value == "New York, NY, USA") {
      this.value = '';
    }
  }).bind("geocode:error", function(event, result){
    console.log(bldg_address, "[ERROR]: " + result);
  });

  $('#filter').keydown(preventEnter);

  $('#filter').keyup(throttledSearch);
  $('#checkbox_active').click(doSearch);
};
$(document).ready(initialize);
