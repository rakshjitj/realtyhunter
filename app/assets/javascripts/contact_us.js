ContactUs = {};

(function() {
	ContactUs.setupSortableColumns = function() {
		$('#contact-us .th-sortable').click(function(e) {
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
			ContactUs.doSearch(sort_by_col, sort_direction);
		});
	};

	// for searching on the index page
	ContactUs.doSearch = function (sort_by_col, sort_direction) {
		//console.log(sort_by_col, sort_direction);
		var search_path = $('#contact-us-search-filters').attr('data-search-path');

	  Forms.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        name: $('#contact-us #name').val(),
        submitted_date: $('#contact-us #submitted_date').val(),
        status: $('#contact-us #status').val(),
        min_price: $('#contact-us #min_price').val(),
        max_price: $('#contact-us #max_price').val(),
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
	ContactUs.timer;

	ContactUs.clearTimer = function() {
		clearTimeout(ContactUs.timer);
	};

	ContactUs.throttledSearch = function () {
		//clear any interval on key up
		if (ContactUs.timer) {
		  clearTimeout(ContactUs.timer);
		}
	  ContactUs.timer = setTimeout(ContactUs.doSearch, 500);
	};

	ContactUs.initialize = function() {

		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		});
		Forms.hideSpinner();

		// main index table
		ContactUs.setupSortableColumns();

		$('.close').click(function() {
			Forms.hideSpinner();
		});

		// index filtering
		$('#contact-us input').keydown(Forms.preventEnter);
		$('#contact-us #name').bind('railsAutocomplete.select', ContactUs.throttledSearch);
		$('#contact-us #name').change(ContactUs.throttledSearch);
	  $('#contact-us #status').change(ContactUs.throttledSearch);
	  $('#contact-us #min_price').change(ContactUs.throttledSearch);
	  $('#contact-us #max_price').change(ContactUs.throttledSearch);
	  $('#contact-us #submitted_date').blur(ContactUs.throttledSearch);

		// index page - selecting listings menu dropdown
		$('#contact-us #emailListings').click(Forms.sendMessage);
		$('#contact-us #deleteMultiple').click(Forms.deleteMultiple);

		$('#contact-us tbody').on('click', 'i', Forms.toggleListingSelection);
		$('#contact-us .select-all-listings').click(Forms.selectAllListings);
		$('#contact-us .selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Forms.indexMenuActions) Forms.indexMenuActions[action]();
		});

	};

})();

$(document).ready(ContactUs.initialize);