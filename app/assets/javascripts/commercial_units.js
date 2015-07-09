(function() {
	   //call when typing or enter or focus leaving
  function initialize() {
  	
  	$(".panel").geocomplete({
    	map: "#map_canvas",
    	location: "<%= @commercial_unit.building.formatted_street_address %>" ,
    	details: ".details"
    }).bind("geocode:result", function(event, result){
        //console.log(result);
    }).bind("geocode:error", function(event, result){
        //console.log("[ERROR]: " + result);
    });

    $('.btn-print-list').click( function(event) {
      // show spinner
      $(this).toggleClass('active');
      timer2 = setTimeout(clearSpinner, 15000);
    });

    function doSearch(event) {

      // sanitize invalid input before submitting
      if ($('#neighborhood_ids').val() == "{:id=>\"neighborhood_ids\"}") {
        $('#neighborhood_ids').val('');
      }

      $.ajax({
        url: "<%= filter_commercial_units_path %>",
        data: {
          search_params: {
            address: $('#address').val(),
            rent_min: $('#rent_min').val(),
            rent_max: $('#rent_max').val(),
            landlord: $('#landlord').val(),
            status: $('#status').val(),
            status: $('#property_type').val(),
            status: $('#listing_id').val(),
            neighborhood_ids: $('#neighborhood_ids').val(),
          } 
        },
        dataType: "script"
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
        //$('#checkbox_active').focus();
        return false;
      }
    };

    $('input').keydown(preventEnter);
    $('#address').keyup(throttledSearch);
    $('#rent_min').keyup(throttledSearch);
    $('#rent_max').keyup(throttledSearch);
    $('#landlord').keyup(throttledSearch);
    $('#status').change(throttledSearch);
    $('#neighborhood_ids').change(throttledSearch);
    $('#property_type').change(throttledSearch);
    $('#listing_id').keyup(throttledSearch);
  };
  // TODO: get rid of document.ready
  $(document).ready(initialize);
})();