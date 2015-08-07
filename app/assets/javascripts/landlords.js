Landlords = {};

(function() {

  Landlords.showSpinner = function() {
    $('#landlords .index-spinner-desktop').show();
  };

  Landlords.hideSpinner = function() {
    $('#landlords .index-spinner-desktop').hide();
  };

  Landlords.doSearch = function(event) {
    var search_path = $('#landlord-search-filters').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        filter: $('#filter').val(),
        active_only: $('#checkbox_active').prop('checked')
      },
      dataType: "script",
      success: function(data) {
        //console.log('SUCCESS:', data.responseText);
        Landlords.hideSpinner();
      },
      error: function(data) {
        //console.log('ERROR:', data.responseText);
        Landlords.hideSpinner();
      }
    });
  };

  // search as user types
  Landlords.timer;
  Landlords.throttledSearch = function() {
    Landlords.showSpinner();
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

    Landlords.hideSpinner();
    $('#landlords a').click(function() {
      Landlords.showSpinner();
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

    $('#landlords #filter').bind('railsAutocomplete.select', Landlords.throttledSearch);
    $('#landlords #filter').keydown(Landlords.preventEnter);
    $('#landlords #filter').change(Landlords.throttledSearch);
    $('#landlords #checkbox_active').click(Landlords.throttledSearch);
  };
})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    Landlords.hideSpinner();
  }
});

$(document).ready(Landlords.initialize);