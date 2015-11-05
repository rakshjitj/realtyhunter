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

	Announcements.timer;

	Announcements.clearTimer = function() {
		if (Announcements.timer) {
		  clearTimeout(Announcements.timer);
		}
	};

	Announcements.throttledSearch = function () {
		//clear any interval on key up
		CommercialUnits.clearTimer();
		SalesListings.clearTimer();
		ResidentialListings.clearTimer();
		Announcements.clearTimer();
	  Announcements.timer = setTimeout(Announcements.doSearch, 500);
	};

	// if a user remains on this page for an extended amount of time,
	// refresh the page every so often. We want to make sure they are
	// always viewing the latest data.
	Announcements.passiveRealTimeUpdate = function() {
		CommercialUnits.clearTimer();
		SalesListings.clearTimer();
		ResidentialListings.clearTimer();
		Announcements.clearTimer();
		// update every few minutes
	  Announcements.timer = setTimeout(Announcements.doSearch, 60 * 1 * 1000);
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

		Announcements.passiveRealTimeUpdate();
	};

	Announcements.initialize = function() {
		// hide spinner on main index when first pulling up the page
		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		  Announcements.passiveRealTimeUpdate();
		});

		$('#announcements #address').bind('railsAutocomplete.select', Announcements.updateUnits);

		$('#announcements #filter_address').bind('railsAutocomplete.select', Announcements.throttledSearch);
		$('#announcements #filter_address').change(Announcements.throttledSearch);
		$('#announcements #created_start').blur(Announcements.throttledSearch);
		$('#announcements #created_end').blur(Announcements.throttledSearch);

		Announcements.passiveRealTimeUpdate();
	};

})();

$(document).ready(Announcements.initialize);