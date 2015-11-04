Announcements = {};

(function() {
	Announcements.updateUnits = function() {
		//console.log($('#announcements #address').val());
		$.ajax({
      url: "/announcements/get_units",
      data: {
        address: $('#announcements #address').val()
      },
      dataType: "script",
    });
	};

	Announcements.throttledSearch = function () {
		//clear any interval on key up
		// CommercialUnits.clearTimer();
		// SalesListings.clearTimer();
		// ResidentialListings.clearTimer();
	  Announcements.timer = setTimeout(Announcements.doSearch, 500);
	};

	Announcements.doSearch = function(res_limit, com_limit, sales_limit, event_limit) {
		var search_path = $('#announcement-search-filters').attr('data-search-path');
	  
	  Forms.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        filter_address: $('#announcements #filter_address').val(),
        created_start: $('#announcements #created_start').val(),
        created_end: $('#announcements #created_end').val(),
        res_limit: $('#announcements #res_limit').val(),
        com_limit: $('#announcements #com_limit').val(),
        sales_limit: $('#announcements #sales_limit').val(),
        event_limit: $('#announcements #event_limit').val(),
	    },
	    dataType: 'script',
	    success: function(data) {
	    	Forms.hideSpinner();
			},
			error: function(data) {
				Forms.hideSpinner();
			}
	  });

		//Announcements.passiveRealTimeUpdate();
	};

	Announcements.initialize = function() {
		$('#announcements #address').bind('railsAutocomplete.select', Announcements.updateUnits);

		$('#announcements #filter_address').bind('railsAutocomplete.select', Announcements.throttledSearch);
		$('#announcements #filter_address').change(Announcements.throttledSearch);
		$('#announcements #created_start').blur(Announcements.throttledSearch);
		$('#announcements #created_end').blur(Announcements.throttledSearch);
	};

})();

$(document).ready(Announcements.initialize);