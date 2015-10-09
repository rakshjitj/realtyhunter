Wufoo = {};

(function() {
	Wufoo.selectedEntries = [];
	Wufoo.selectedRoommateEmails = [];
	// private
	Wufoo.checkTheBox = function(item) {
		item.addClass('fa-check-square').removeClass('fa-square-o');
	};
	// private
	Wufoo.uncheckTheBox = function(item) {
		item.addClass('fa-square-o').removeClass('fa-check-square');
	};
	// private
	Wufoo.updateSelectedButton = function() {
		$('#selected-listings-dropdown').html(Wufoo.selectedEntries.length + " Selected Wufoo <span class=\"caret\"></span>");
		if (Wufoo.selectedEntries.length == 0) {
			$('#selected-listings-dropdown').addClass("disabled");
		} else {
			$('#selected-listings-dropdown').removeClass("disabled");
		}

		// update the hidden tag with the latest list of ids
		//$('#roommate_listing_ids').val(Wufoo.selectedEntries);
	};
	// private
	// if any individual listings get unchecked, then uncheck
	// the main toggle inside our th
	Wufoo.uncheckHeadToggle = function() {
		Wufoo.uncheckTheBox($('th > i'));
	};

	Wufoo.selectAllListings = function() {
		var isChecked = $(this).hasClass('fa-check-square');
		if (isChecked) {
			// uncheck all boxes, clear our list
			Wufoo.uncheckTheBox($(this));
			Wufoo.selectedEntries = [];
			Wufoo.selectedRoommateEmails = [];

			$('td > i').map(function() {
				if ($(this).hasClass('fa-check-square')) {
					Wufoo.uncheckTheBox($(this));
				}
			});
		} else {
			// check all boxes, fill our list
			Wufoo.checkTheBox($(this));
			Wufoo.selectedEntries = $('tr').map(function() {
				return $(this).attr('data-id');
			}).get();

			Wufoo.selectedRoommateEmails = $('tr').map(function() {
				return $(this).attr('data-email');
			}).get();

			$('td > i').map(function() {
				if ($(this).hasClass('fa-square-o')) {
					Wufoo.checkTheBox($(this));
				}
			});
		}

		Wufoo.updateSelectedButton();
	};

	Wufoo.toggleListingSelection = function() {
		// TODO: cap the max # of listings you can select?
		var isChecked = $(this).hasClass('fa-check-square');
		var roommate_id = $(this).parent().parent().attr('data-id');
		var roommate_email = $(this).parent().parent().attr('data-email');

		if (isChecked) {
			Wufoo.uncheckTheBox($(this));
			Wufoo.selectedEntries.splice(Wufoo.selectedEntries.indexOf(roommate_id), 1);
			Wufoo.selectedRoommateEmails.splice(Wufoo.selectedRoommateEmails.indexOf(roommate_email), 1);
			Wufoo.uncheckHeadToggle();
		} else {
			Wufoo.checkTheBox($(this));
			Wufoo.selectedEntries.push(roommate_id);
			Wufoo.selectedRoommateEmails.push(roommate_email);
		}

		Wufoo.updateSelectedButton();
	};

	Wufoo.sendMessage = function (e) {
		Wufoo.hideSpinner();
		$('#contact_us_recipients').val(Wufoo.selectedRoommateEmails.join(","));
		$('#contact_us_message').val('');
		e.preventDefault();
	};

	Wufoo.indexMenuActions = {
		'PDF': function() {
			var params = 'entry_ids=' + Wufoo.selectedEntries.join(",");
			window.location.href = '/forms/contact_us/download.pdf?' + params;
		},
		'CSV': function() {
			var params = 'entry_ids=' + Wufoo.selectedEntries.join(",");
			window.location.href = '/forms/contact_us/download.csv?' + params;
		}
	};

	Wufoo.showSpinner = function() {
		$('.contact_us-spinner-desktop').show();
	};

	Wufoo.hideSpinner = function() {
		$('.contact_us-spinner-desktop').hide();
	};

	// for searching on the index page
	Wufoo.doSearch = function (sort_by_col, sort_direction) {
		//console.log(sort_by_col, sort_direction);
		var search_path = $('#contact-us-search-filters').attr('data-search-path');
	  
	  Wufoo.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        name: $('#contact-us #name').val(),
        status: $('#contact-us #status').val(),
        min_price: $('#contact-us #min_price').val(),
        max_price: $('#contact-us #max_price').val(),
        sort_by: sort_by_col,
        direction: sort_direction,
	    },
	    dataType: 'script',
	    success: function(data) {
	    	Wufoo.hideSpinner();
			},
			error: function(data) {
				Wufoo.hideSpinner();
			}
	  });
	};

	// search as user types
	Wufoo.timer;

	Wufoo.throttledSearch = function () {
		//clear any interval on key up
		if (Wufoo.timer) {
		  clearTimeout(Wufoo.timer);
		}
	  Wufoo.timer = setTimeout(Wufoo.doSearch, 500);
	};

	// change enter key to tab
	Wufoo.preventEnter = function (event) {
	  if (event.keyCode == 13) {
	    return false;
	  }
	};

	Wufoo.setupSortableColumns = function() {
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
			Wufoo.doSearch(sort_by_col, sort_direction);
		});
	};

	Wufoo.initialize = function() {
		document.addEventListener("page:restore", function() {
		  Wufoo.hideSpinner();
		});
		Wufoo.hideSpinner();
		$('#contact-us a').click(function() {
			Wufoo.showSpinner();
		});

		// main index table
		Wufoo.setupSortableColumns();		

		$('.close').click(function() {
			Wufoo.hideSpinner();
		});

		// index filtering
		$('#contact-us input').keydown(Wufoo.preventEnter);
		$('#contact-us #name').bind('railsAutocomplete.select', Wufoo.throttledSearch);
	  $('#contact-us #status').change(Wufoo.throttledSearch);
	  $('#contact-us #min_price').change(Wufoo.throttledSearch);
	  $('#contact-us #max_price').change(Wufoo.throttledSearch);
	  
		// index page - selecting listings menu dropdown
		$('#contact-us #emailListings').click(Wufoo.sendMessage);
		$('#contact-us tbody').on('click', 'i', Wufoo.toggleListingSelection);
		$('#contact-us .select-all-listings').click(Wufoo.selectAllListings);
		Wufoo.selectedEntries = [];
		Wufoo.selectedRoommateEmails = [];
		$('#contact-us .selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Wufoo.indexMenuActions) Wufoo.indexMenuActions[action]();
		});

	};

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
  	Wufoo.hideSpinner();
  }
});

$(document).ready(Wufoo.initialize);
