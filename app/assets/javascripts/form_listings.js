/*
* NOTE: This code is currently not being used.
* It was designed to be used in conjunction with
* forms/residential_listings and forms/commercial_listings
*/

FormListings = {};

(function() {
	FormListings.setupSortableColumns = function() {
		$('#form-listing .th-sortable').click(function(e) {
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
			FormListings.doSearch(sort_by_col, sort_direction);
		});
	};

	// for searching on the index page
	FormListings.doSearch = function (sort_by_col, sort_direction) {
		var search_path = $('#form-listing-search-filters').attr('data-search-path');
	  
	  Forms.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        name: $('#form-listing #name').val(),
        email: $('#form-listing #email').val(),
        status: $('#form-listing #status').val(),
        submitted_date: $('#form-listing #submitted_date').val(),
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
	FormListings.timer;

	FormListings.throttledSearch = function () {
		//clear any interval on key up
		if (FormListings.timer) {
		  clearTimeout(FormListings.timer);
		}
	  FormListings.timer = setTimeout(FormListings.doSearch, 500);
	};

	FormListings.initialize = function() {

		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		});
		Forms.hideSpinner();

		// main index table
		FormListings.setupSortableColumns();		

		$('.close').click(function() {
			Forms.hideSpinner();
		});

		// index filtering
		$('#form-listing input').keydown(Forms.preventEnter);
		$('#form-listing #name').bind('railsAutocomplete.select', FormListings.throttledSearch);
		$('#form-listing #name').change(FormListings.throttledSearch);
	  $('#form-listing #status').change(FormListings.throttledSearch);
	  $('#form-listing #email').change(FormListings.throttledSearch);
	  $('#form-listing #email').bind('railsAutocomplete.select', FormListings.throttledSearch);
	  $('#form-listing #submitted_date').blur(FormListings.throttledSearch);

		// index page - selecting listings menu dropdown
		$('#form-listing #emailListings').click(Forms.sendMessage);
		$('#form-listing tbody').on('click', 'i', Forms.toggleListingSelection);
		$('#form-listing .select-all-listings').click(Forms.selectAllListings);
		$('#form-listing .selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Forms.indexMenuActions) Forms.indexMenuActions[action]();
		});

	};

})();

$(document).ready(FormListings.initialize);