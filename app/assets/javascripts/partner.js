Partner = {};

(function() {
	Partner.setupSortableColumns = function() {
		$('#partner .th-sortable').click(function(e) {
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
			Partner.doSearch(sort_by_col, sort_direction);
		});
	};

	// for searching on the index page
	Partner.doSearch = function (sort_by_col, sort_direction) {
		var search_path = $('#partner-search-filters').attr('data-search-path');

	  Forms.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        name: $('#partner #name').val(),
        submitted_date: $('#partner #submitted_date').val(),
        status: $('#partner #status').val(),
        address_street_address: $('#partner #address_street_address').val(),
        number_of_bedrooms: $('#partner #number_of_bedrooms').val(),
        move_in_date: $('#partner #move_in_date').val(),
        renovated: $('#partner #renovated').val(),
        sort_by: sort_by_col,
        direction: sort_direction,
	    },
	    dataType: 'script',
	    success: function(data) {
	    	Forms.hideSpinner();
			},
			error: function(data) {
				Forms.hideSpinner();
			}
	  });
	};

	// search as user types
	Partner.timer;

	Partner.clearTimer = function() {
		clearTimeout(Partner.timer);
	};

	Partner.throttledSearch = function () {
		//clear any interval on key up
		if (Partner.timer) {
		  clearTimeout(Partner.timer);
		}
	  Partner.timer = setTimeout(Partner.doSearch, 500);
	};

	Partner.initialize = function() {

		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		});
		Forms.hideSpinner();

		// main index table
		Partner.setupSortableColumns();

		$('.close').click(function() {
			Forms.hideSpinner();
		});

		// index filtering
		$('#partner input').keydown(Forms.preventEnter);
		$('#partner #name').bind('railsAutocomplete.select', Partner.throttledSearch);
		$('#partner #name').change(Partner.throttledSearch);
	  $('#partner #status').change(Partner.throttledSearch);
	  $('#partner #address_street_address').change(Partner.throttledSearch);
	  $('#partner #address_street_address').bind('railsAutocomplete.select', Partner.throttledSearch);
	  $('#partner #number_of_bedrooms').change(Partner.throttledSearch);
	  $('#partner #move_in_date').blur(Partner.throttledSearch);
	  $('#partner #submitted_date').blur(Partner.throttledSearch);
	  $('#partner #renovated').change(Partner.throttledSearch);

		// index page - selecting listings menu dropdown
		$('#partner #emailListings').click(Forms.sendMessage);
		$('#partner #deleteMultiple').click(Forms.deleteMultiple);

		$('#partner tbody').on('click', 'i', Forms.toggleListingSelection);
		$('#partner .select-all-listings').click(Forms.selectAllListings);
		$('#partner .selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Forms.indexMenuActions) Forms.indexMenuActions[action]();
		});

	};

})();

$(document).ready(Partner.initialize);