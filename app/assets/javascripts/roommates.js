Roommates = {};

(function() {
	Roommates.selectedRoommates = [];
	Roommates.selectedRoommateEmails = [];
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
		$('#selected-listings-dropdown').html(Roommates.selectedRoommates.length + " Selected Roommates <span class=\"caret\"></span>");
		if (Roommates.selectedRoommates.length == 0) {
			$('#selected-listings-dropdown').addClass("disabled");
		} else {
			$('#selected-listings-dropdown').removeClass("disabled");
		}

		// update the hidden tag with the latest list of ids
		$('#roommate_listing_ids').val(Roommates.selectedRoommates);
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
			Roommates.selectedRoommates = [];
			Roommates.selectedRoommateEmails = [];

			$('td > i').map(function() {
				if ($(this).hasClass('fa-check-square')) {
					Roommates.uncheckTheBox($(this));
				}
			});
		} else {
			// check all boxes, fill our list
			Roommates.checkTheBox($(this));
			Roommates.selectedRoommates = $('tr').map(function() {
				return $(this).attr('data-id');
			}).get();

			Roommates.selectedRoommateEmails = $('tr').map(function() {
				return $(this).attr('data-email');
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
		var roommate_id = $(this).parent().parent().attr('data-id');
		var roommate_email = $(this).parent().parent().attr('data-email');

		if (isChecked) {
			//$(this).addClass('fa-square-o').removeClass('fa-check-square');
			Roommates.uncheckTheBox($(this));
			Roommates.selectedRoommates.splice(Roommates.selectedRoommates.indexOf(roommate_id), 1);
			Roommates.selectedRoommateEmails.splice(Roommates.selectedRoommateEmails.indexOf(roommate_email), 1);
			Roommates.uncheckHeadToggle();
		} else {
			//$(this).addClass('fa-check-square').removeClass('fa-square-o');
			Roommates.checkTheBox($(this));
			Roommates.selectedRoommates.push(roommate_id);
			Roommates.selectedRoommateEmails.push(roommate_email);
		}

		Roommates.updateSelectedButton();
	};

	// email modal triggered
	Roommates.sendMessage = function (e) {
		$('#roommate_recipients').val('');
		$('#roommate_ids').val(Roommates.selectedRoommates.join(","));
		$('#roommate_message').val('');
		e.preventDefault();
	};

	// match modal triggered
	Roommates.matchMultiple = function(e) {
		$.ajax({
	    url: 'roommates/match_multiple_modal',
	    data: {
        ids: Roommates.selectedRoommates,
	    },
	    dataType: 'script'
	  });
	};

	Roommates.deleteMultiple = function() {
		$.ajax({
	    url: 'roommates/destroy_multiple_modal',
	    data: {
        ids: Roommates.selectedRoommates,
	    },
	    dataType: 'script'
	  });
	};

	Roommates.indexMenuActions = {
		'mark-read': function() {
			$.ajax({
				type: 'PATCH',
		    url: 'roommates/mark_read',
		    data: {
	        ids: Roommates.selectedRoommates,
		    },
		    dataType: 'script'
		  });
		},
		'PDF': function() {
			var params = 'roommate_ids=' + Roommates.selectedRoommates.join(",");
			window.location.href = '/roommates/download.pdf?' + params;
		},
		'CSV': function() {
			var params = 'roommate_ids=' + Roommates.selectedRoommates.join(",");
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
	Roommates.doSearch = function (sortByCol, sortDirection) {
		var search_path = $('#room-search-filters').attr('data-search-path');

	  Roommates.showSpinner();

	  if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
      name: $('#roommates #name').val(),
      referred_by: $('#roommates #referred_by').val(),
      neighborhood_id: $('#roommates #neighborhood_id').val(),
      submitted_date: $('#roommates #submitted_date').val(),
      move_in_date: $('#roommates #move_in_date').val(),
      monthly_budget: $('#roommates #monthly_budget').val(),
      dogs_allowed: $('#roommates #dogs_allowed').val(),
      cats_allowed: $('#roommates #cats_allowed').val(),
      status: $('#roommates #status').val(),
      sort_by: sortByCol,
      direction: sortDirection,
    };

    var searchParams = [];
    for(var key in data) {
      if (data.hasOwnProperty(key) && data[key]) {
        searchParams.push(key + "=" + data[key]);
      }
    }
    window.location.search = searchParams.join('&');

	  // $.ajax({
	  //   url: search_path,
	  //   data: {
   //      name: $('#roommates #name').val(),
   //      referred_by: $('#roommates #referred_by').val(),
   //      neighborhood_id: $('#roommates #neighborhood_id').val(),
   //      submitted_date: $('#roommates #submitted_date').val(),
   //      move_in_date: $('#roommates #move_in_date').val(),
   //      monthly_budget: $('#roommates #monthly_budget').val(),
   //      dogs_allowed: $('#roommates #dogs_allowed').val(),
   //      cats_allowed: $('#roommates #cats_allowed').val(),
   //      status: $('#roommates #status').val(),
   //      sort_by: sortByCol,
   //      direction: sortDirection,
	  //   },
	  //   dataType: 'script',
	  //   success: function(data) {
	  //   	//console.log('SUCCESS:', data.responseText);
	  //   	Roommates.hideSpinner();
			// },
			// error: function(data) {
			// 	//console.log('ERROR:', data.responseText);
			// 	Roommates.hideSpinner();
			// }
	  // });
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

	Roommates.sortOnColumnClick = function() {
		$('#roommates .th-sortable').click(function(e) {
			Common.sortOnColumnClick($(this), Roommates.doSearch);
		});
	};

	Roommates.updateUnits = function() {
		$.ajax({
      url: "/roommates/get_units",
      data: {
      	//ids: $('#roommateMatchModal #ids').val(),
      	ids: Roommates.selectedRoommates,
        address: $('#roommateMatchModal #address').val()
      },
      dataType: "script",
    });
	};

	Roommates.checkUnitForAvailability = function() {
		$.ajax({
      url: "/roommates/check_availability",
      data: {
      	//ids: $('#roommateMatchModal #ids').val(),
      	ids: Roommates.selectedRoommates,
        unit_id: $('#roommateMatchModal #unit_id').val()
      },
      dataType: "script",
    });
	};

	Roommates.initialize = function() {
		if (!$('#roommates').length) {
			return;
		}

		document.addEventListener("page:restore", function() {
		  Roommates.hideSpinner();
		});
		Roommates.hideSpinner();

		// main index table
		Roommates.sortOnColumnClick();
		Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="submitted_date"]'), 'desc')
    }

		$('.close').click(function() {
			//console.log('detected click');
			Roommates.hideSpinner();
		});

		$('.datepicker').datetimepicker({
		  viewMode: 'days',
		  format: 'MM/DD/YYYY',
		  allowInputToggle: true
		});

		// index filtering
		$('#roommates input').keydown(Roommates.preventEnter);
		$('#roommates #name').bind('railsAutocomplete.select', Roommates.throttledSearch);
		$('#roommates #name').change(Roommates.throttledSearch);
	  $('#roommates #referred_by').change(Roommates.throttledSearch);
	  $('#roommates #neighborhood_id').change(Roommates.throttledSearch);
	  $('#roommates #submitted_date').blur(Roommates.throttledSearch);
	  $('#roommates #move_in_date').blur(Roommates.throttledSearch);
	  $('#roommates #monthly_budget').change(Roommates.throttledSearch);
	  $('#roommates #dogs_allowed').change(Roommates.throttledSearch);
	  $('#roommates #cats_allowed').change(Roommates.throttledSearch);
	  $('#roommates #status').change(Roommates.throttledSearch);

		// index page - selecting listings menu dropdown
		$('#roommates #emailListings').click(Roommates.sendMessage);
		$('#roommates #matchMultiple').click(Roommates.matchMultiple);
		$('#roommates #deleteMultiple').click(Roommates.deleteMultiple);

		$('#roommates tbody').on('click', 'i', Roommates.toggleListingSelection);
		$('#roommates .select-all-listings').click(Roommates.selectAllListings);
		Roommates.selectedRoommates = [];
		Roommates.selectedRoommateEmails = [];
		$('#roommates .selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Roommates.indexMenuActions) Roommates.indexMenuActions[action]();
		});

		// when a unit is selected, check to see if there's enough space for all these roommates
		$('#roommateMatchModal').on('change', '#unit_id', Roommates.checkUnitForAvailability);

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
