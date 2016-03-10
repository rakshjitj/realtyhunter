Announcements = {};

(function() {

	Announcements.timer;

	Announcements.clearTimer = function() {
		if (Announcements.timer) {
		  clearTimeout(Announcements.timer);
		}
	};

	Announcements.throttledSearch = function () {
		//clear any interval on key up
		Announcements.clearTimer();
	  Announcements.timer = setTimeout(Announcements.doSearch, 500);
	};

	// if a user remains on this page for an extended amount of time,
	// refresh the page every so often. We want to make sure they are
	// always viewing the latest data.
	Announcements.passiveRealTimeUpdate = function() {
		if ($('#announcements').length > 0 ) {
			Announcements.clearTimer();
			// update every few minutes
		  Announcements.timer = setTimeout(Announcements.doSearch, 60 * 2 * 1000);
		}
	};

	Announcements.doSearch = function(res_limit, com_limit, sales_limit, event_limit) {
		var search_path = $('#announcement-search-filters').attr('data-search-path');

	  Forms.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        created_start: $('#announcements #created_start').val(),
        created_end: $('#announcements #created_end').val(),
        category_filter: $('#announcements #category_filter').val(),
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
		if ($('.announcements').length) {
			$('#announcements #created_start').blur(Announcements.throttledSearch);
			$('#announcements #created_end').blur(Announcements.throttledSearch);
			$('#announcements #category_filter').change(Announcements.throttledSearch);

			Announcements.passiveRealTimeUpdate();
		}
	};
})();

$(document).on('ready page:load', Announcements.initialize);

$(document).on('page:restore', Announcements.initialize);
