Landlords = {};

(function() {

  Landlords.doSearch = function(event) {
    var search_path = $('#landlord-search-filters').attr('data-search-path');
    $.ajax({
      url: search_path,
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
  Landlords.timer;
  Landlords.throttledSearch = function() {
    // only accept letter/number keys as search input
    // var charTyped = String.fromCharCode(e.which);
    // if (/[a-z\d]/i.test(charTyped)) {
    //     console.log("Letter or number typed: " + charTyped);
    // } else {
    //   return;
    // }
    
    clearTimeout(Landlords.timer);  //clear any interval on key up
    Landlords.timer = setTimeout(Landlords.doSearch, 500);
  };

  // change enter key to tab
  Landlords.preventEnter = function(event) {
    if (event.keyCode == 13) {
      $('#checkbox_active').focus();
      return false;
    }
  };

  Landlords.initialize = function() {
    // change all date input fields to auto-open the calendar
    $('.datepicker').datetimepicker({
      viewMode: 'days',
      format: 'MM/DD/YYYY',
      allowInputToggle: true
    });
    
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

    $('#filter').keydown(Landlords.preventEnter);

    $('#filter').change(Landlords.throttledSearch);
    $('#checkbox_active').click(Landlords.doSearch);
  };
})();

$(document).ready(Landlords.initialize);
  
