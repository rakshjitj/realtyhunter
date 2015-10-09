Forms = {};

(function() {
	Forms.selectedEntries = [];
	Forms.selectedRoommateEmails = [];

	Forms.checkTheBox = function(item) {
		item.addClass('fa-check-square').removeClass('fa-square-o');
	};

	Forms.uncheckTheBox = function(item) {
		item.addClass('fa-square-o').removeClass('fa-check-square');
	};

	Forms.updateSelectedButton = function() {
		$('#selected-listings-dropdown').html(Forms.selectedEntries.length + " Selected Wufoo <span class=\"caret\"></span>");
		if (Forms.selectedEntries.length == 0) {
			$('#selected-listings-dropdown').addClass("disabled");
		} else {
			$('#selected-listings-dropdown').removeClass("disabled");
		}
	};

	// if any individual listings get unchecked, then uncheck
	// the main toggle inside our th
	Forms.uncheckHeadToggle = function() {
		Forms.uncheckTheBox($('th > i'));
	};

	Forms.selectAllListings = function() {
		var isChecked = $(this).hasClass('fa-check-square');
		if (isChecked) {
			// uncheck all boxes, clear our list
			Forms.uncheckTheBox($(this));
			Forms.selectedEntries = [];
			Forms.selectedRoommateEmails = [];

			$('td > i').map(function() {
				if ($(this).hasClass('fa-check-square')) {
					Forms.uncheckTheBox($(this));
				}
			});
		} else {
			// check all boxes, fill our list
			Forms.checkTheBox($(this));
			Forms.selectedEntries = $('tr').map(function() {
				return $(this).attr('data-id');
			}).get();

			Forms.selectedRoommateEmails = $('tr').map(function() {
				return $(this).attr('data-email');
			}).get();

			$('td > i').map(function() {
				if ($(this).hasClass('fa-square-o')) {
					Forms.checkTheBox($(this));
				}
			});
		}

		Forms.updateSelectedButton();
	};

	Forms.toggleListingSelection = function() {
		// TODO: cap the max # of listings you can select?
		var isChecked = $(this).hasClass('fa-check-square');
		var roommate_id = $(this).parent().parent().attr('data-id');
		var roommate_email = $(this).parent().parent().attr('data-email');

		if (isChecked) {
			Forms.uncheckTheBox($(this));
			Forms.selectedEntries.splice(Forms.selectedEntries.indexOf(roommate_id), 1);
			Forms.selectedRoommateEmails.splice(Forms.selectedRoommateEmails.indexOf(roommate_email), 1);
			Forms.uncheckHeadToggle();
		} else {
			Forms.checkTheBox($(this));
			Forms.selectedEntries.push(roommate_id);
			Forms.selectedRoommateEmails.push(roommate_email);
		}

		Forms.updateSelectedButton();
	};

	Forms.sendMessage = function (e) {
		$('#contact_us_recipients').val(Forms.selectedRoommateEmails.join(","));
		$('#contact_us_message').val('');
		e.preventDefault();
	};

	Forms.indexMenuActions = {
		'PDF': function() {
			var params = 'entry_ids=' + Forms.selectedEntries.join(",");
			window.location.href = '/forms/contact_us/download.pdf?' + params;
		},
		'CSV': function() {
			var params = 'entry_ids=' + Forms.selectedEntries.join(",");
			window.location.href = '/forms/contact_us/download.csv?' + params;
		}
	};

	Forms.showSpinner = function() {
		$('.wufoo-spinner-desktop').show();
	};

	Forms.hideSpinner = function() {
		$('.wufoo-spinner-desktop').hide();
	};

	// change enter key to tab
	Forms.preventEnter = function (event) {
	  if (event.keyCode == 13) {
	    return false;
	  }
	};

	Forms.setupSortableColumns = function() {
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
			Forms.doSearch(sort_by_col, sort_direction);
		});
	};

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
  	Forms.hideSpinner();
  }
});

////-------------------------------------------
ContactUs = {};
(function() {
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
		Forms.setupSortableColumns();		

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
		$('#contact-us tbody').on('click', 'i', Forms.toggleListingSelection);
		$('#contact-us .select-all-listings').click(Forms.selectAllListings);
		$('#contact-us .selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Forms.indexMenuActions) Forms.indexMenuActions[action]();
		});

		// make sure datepicker is formatted before setting initial date below
		$('.datepicker').datetimepicker({
		  viewMode: 'days',
		  format: 'MM/DD/YYYY',
		  allowInputToggle: true
		});
		var available_by = $('#roommates .datepicker').attr('data-available-by');
		if (available_by) {
			$('#roommates .datepicker').data("DateTimePicker").date(available_by);
		}
	};

})();

$(document).ready(ContactUs.initialize);