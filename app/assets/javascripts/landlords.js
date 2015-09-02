Landlords = {};

(function() {

  Landlords.showSpinner = function() {
    $('#landlords .ll-spinner-desktop').show();
  };

  Landlords.hideSpinner = function() {
    $('#landlords .ll-spinner-desktop').hide();
  };

  Landlords.filterListings = function(event) {
    var search_path = $('#listings').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        active_only: $('#landlords #listings_checkbox_active').prop('checked')
      },
      dataType: "script",
      success: function(data) {
        Landlords.hideSpinner();
      },
      error: function(data) {
        Landlords.hideSpinner();
      }
    });
  };

  Landlords.doSearch = function(sort_by_col, sort_direction) {
    //console.log(sort_by_col, sort_direction);
    var search_path = $('#landlord-search-filters').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        filter: $('#filter').val(),
        active_only: $('#checkbox_active').prop('checked'),
        sort_by: sort_by_col,
        direction: sort_direction,
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

  Landlords.setupSortableColumns = function() {
    $('#landlords .th-sortable').click(function(e) {
      e.preventDefault();
      
      if ($(this).hasClass('selected-sort')) {
        // switch sort order
        var i = $('.selected-sort i');
        if (i) {
          if (i.hasClass('glyphicon glyphicon-triangle-bottom')) {
            i.removeClass('glyphicon glyphicon-triangle-bottom').addClass('glyphicon glyphicon-triangle-top');
            $(this).attr('data-direction', 'desc');
          }
          else if (i.hasClass('glyphicon glyphicon-triangle-top')) {
            i.removeClass('glyphicon glyphicon-triangle-top').addClass('glyphicon glyphicon-triangle-bottom');
            $(this).attr('data-direction', 'asc');
          }
        }
      } else {
        // remove selection from old row
        $('.selected-sort').attr('data-direction', '');
        $('th i').remove(); // remove arrows
        $('.selected-sort').removeClass('selected-sort');
        // select new column
        $(this).addClass('selected-sort').append(' <i class="glyphicon glyphicon-triangle-bottom"></i>');
        $(this).attr('data-direction', 'asc');
      }

      var sort_by_col = $(this).attr('data-sort');
      var sort_direction = $(this).attr('data-direction');
      Landlords.doSearch(sort_by_col, sort_direction);
    });
  };

  // search as user types
  Landlords.timer;
  Landlords.throttledSearch = function() {
    Landlords.showSpinner();
    
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

  Landlords.toggleFeeOptions = function(event) {
    var isChecked = $('#landlords .has-fee').prop('checked');
    if (isChecked) {
      $('#landlords .show-op').addClass('hide');
      $('#landlords .show-tp').removeClass('hide');
    } else {
      $('#landlords .show-op').removeClass('hide');
      $('#landlords .show-tp').addClass('hide');
    }
  };

  Landlords.initialize = function() {

    document.addEventListener("page:restore", function() {
      Landlords.hideSpinner();
    });
    Landlords.hideSpinner();
    $('#landlords a').click(function() {
      Landlords.showSpinner();
    });

    // main index table
    Landlords.setupSortableColumns();

    $('#landlords .has-fee').click(Landlords.toggleFeeOptions);
    Landlords.toggleFeeOptions();

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
    $('#landlords #listings_checkbox_active').click(Landlords.filterListings);
  };
})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    Landlords.hideSpinner();
  }
});

$(document).ready(Landlords.initialize);