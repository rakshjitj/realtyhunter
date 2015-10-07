Roommates = {};

(function() {
	Roommates.selectedListings = [];

	// private
	Roommates.checkTheBox = function(item) {
		item.addClass('fa-check-square').removeClass('fa-square-o');
	};
	// private
	Roommates.uncheckTheBox = function(item) {
		item.addClass('fa-square-o').removeClass('fa-check-square');
	};
	// private
	Roommates.updateSelectedButton = function() {
		$('#selected-listings-dropdown').html(Roommates.selectedListings.length + " Selected Roommates <span class=\"caret\"></span>");
		if (Roommates.selectedListings.length == 0) {
			$('#selected-listings-dropdown').addClass("disabled");
		} else {
			$('#selected-listings-dropdown').removeClass("disabled");
		}

		// update the hidden tag with the latest list of ids
		$('#roommate_listing_ids').val(Roommates.selectedListings);
	};
	// private
	// if any individual listings get unchecked, then uncheck
	// the main toggle inside our th
	Roommates.uncheckHeadToggle = function() {
		Roommates.uncheckTheBox($('th > i'));
	};

	Roommates.selectAllListings = function() {
		var isChecked = $(this).hasClass('fa-check-square');
		if (isChecked) {
			// uncheck all boxes, clear our list
			Roommates.uncheckTheBox($(this));
			Roommates.selectedListings = [];

			$('td > i').map(function() {
				if ($(this).hasClass('fa-check-square')) {
					Roommates.uncheckTheBox($(this));
				}
			});
		} else {
			// check all boxes, fill our list
			Roommates.checkTheBox($(this));
			Roommates.selectedListings = $('tr').map(function() {
				return $(this).attr('data-id');
			}).get();

			$('td > i').map(function() {
				if ($(this).hasClass('fa-square-o')) {
					Roommates.checkTheBox($(this));
				}
			});
		}

		Roommates.updateSelectedButton();
	};

	Roommates.toggleListingSelection = function() {
		// TODO: cap the max # of listings you can select?
		var isChecked = $(this).hasClass('fa-check-square');
		var listing_id = $(this).parent().parent().attr('data-id');
		
		if (isChecked) {
			//$(this).addClass('fa-square-o').removeClass('fa-check-square');
			Roommates.uncheckTheBox($(this));
			Roommates.selectedListings.splice(Roommates.selectedListings.indexOf(listing_id), 1);
			Roommates.uncheckHeadToggle();
		} else {
			//$(this).addClass('fa-check-square').removeClass('fa-square-o');
			Roommates.checkTheBox($(this));
			Roommates.selectedListings.push(listing_id);
		}

		Roommates.updateSelectedButton();
	};

	Roommates.indexMenuActions = {
		
		'send': function() {
			console.log('sending!');
			var params = 'roommate_ids=' + Roommates.selectedListings.join(",");
			window.location.href = '/roommates/print_list?' + params;
		},
		'PDF': function() {
			//console.log('sheet!');
			var params = 'roommate_ids=' + Roommates.selectedListings.join(",");
			window.location.href = '/roommates/download.pdf?' + params;
		},
		'CSV': function() {
			var params = 'roommate_ids=' + Roommates.selectedListings.join(",");
			window.location.href = '/roommates/download.csv?' + params;
		}
	};

	Roommates.showSpinner = function() {
		$('.room-spinner-desktop').show();
	};

	Roommates.hideSpinner = function() {
		$('.room-spinner-desktop').hide();
	};

	// for searching on the index page
	Roommates.doSearch = function (sort_by_col, sort_direction) {
		//console.log(sort_by_col, sort_direction);
		// sanitize invalid input before submitting
	  // if ($('#rommates #neighborhood_ids').val() == "{:id=>\"neighborhood_ids\"}") {
	  //   $('#rommates #neighborhood_ids').val('');
	  // }

	  var search_path = $('#room-search-filters').attr('data-search-path');
	  
	  Roommates.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        name: $('#roommates #name').val(),
        referred_by: $('#roommates #referred_by').val(),
        neighborhood_id: $('#roommates #neighborhood_id').val(),
        submitted_date: $('#roommates #submitted_date').val(),
        move_in_date: $('#roommates #move_in_date').val(),
        monthly_budget: $('#roommates #monthly_budget').val(),
        dogs_allowed: $('#roommates #dogs_allowed').val(),
        cats_allowed: $('#roommates #cats_allowed').val(),
        status: $('#roommates #status').val(),
        sort_by: sort_by_col,
        direction: sort_direction,
	    },
	    dataType: 'script',
	    success: function(data) {
	    	//console.log('SUCCESS:', data.responseText);
	    	Roommates.hideSpinner();
			},
			error: function(data) {
				//console.log('ERROR:', data.responseText);
				Roommates.hideSpinner();
			}
	  });
	};

	Roommates.removeNeighborhood = function (event) {
  	event.preventDefault();
	  var feature_id = $(this).attr('data-id');
  	var idx = $('#roommates #neighborhood_ids').val().indexOf(feature_id);
  	$('#roommates #neighborhood_ids').val( $('#roommates #neighborhood_ids').val().replace(feature_id, '') );
  	$(this).remove();
  	Roommates.throttledSearch();
  };

	// search as user types
	Roommates.timer;

	Roommates.throttledSearch = function () {
		//console.log('throttling?');
		//clear any interval on key up
		if (Roommates.timer) {
			//console.log('yes, clearing');
		  clearTimeout(Roommates.timer);
		}
	  Roommates.timer = setTimeout(Roommates.doSearch, 500);
	};

	// change enter key to tab
	Roommates.preventEnter = function (event) {
	  if (event.keyCode == 13) {
	    //$('#checkbox_active').focus();
	    return false;
	  }
	};

	Roommates.setupSortableColumns = function() {
		$('#roommates .th-sortable').click(function(e) {
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
			Roommates.doSearch(sort_by_col, sort_direction);
		});
	};

	Roommates.initialize = function() {
		document.addEventListener("page:restore", function() {
		  Roommates.hideSpinner();
		});
		Roommates.hideSpinner();
		$('#roommates a').click(function() {
			Roommates.showSpinner();
		});

		// main index table
		Roommates.setupSortableColumns();		

		$('.close').click(function() {
			//console.log('detected click');
			Roommates.hideSpinner();
		});

		// index filtering
		$('#roommates name').keydown(Roommates.preventEnter);
		$('#roommates #name').bind('railsAutocomplete.select', Roommates.throttledSearch);
	  $('#roommates #referred_by').change(Roommates.throttledSearch);
	  $('#roommates #neighborhood_id').change(Roommates.throttledSearch);
	  $('#roommates #submitted_date').blur(Roommates.throttledSearch);
	  $('#roommates #move_in_date').blur(Roommates.throttledSearch);
	  $('#roommates #monthly_budget').change(Roommates.throttledSearch);
	  $('#roommates #dogs_allowed').change(Roommates.throttledSearch);
	  $('#roommates #cats_allowed').change(Roommates.throttledSearch);
	  $('#roommates #status').change(Roommates.throttledSearch);
	  
	  // remove individual features by clicking on 'x' button
	  $('#roommates .remove-neighborhood').click(Roommates.removeNeighborhood);

	  // print pdf from the index page
	 //  $('#roommates .btn-print-list').click( function(event) {
		//   Roommates.showSpinner();
		//   $(this).toggleClass('active');
		// });

		// index page - selecting listings menu dropdown
		$('#emailListings').click(function(e) {
			$('#roommates_listing_recipients').val('');
			//$('#roommates_listing_title').val('');
			$('#roommates_listing_message').val('');
			e.preventDefault();
		});
		$('tbody').on('click', 'i', Roommates.toggleListingSelection);
		$('.select-all-listings').click(Roommates.selectAllListings);
		Roommates.selectedListings = [];
		$('.selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Roommates.indexMenuActions) Roommates.indexMenuActions[action]();
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

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
  	Roommates.hideSpinner();
  }
});

$(document).ready(Roommates.initialize);
