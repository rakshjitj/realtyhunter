/*
* Factors out common functionality across all listings pages:
* Residential, Commercial, Sales
*/

Listings = {};
(function() {

	Listings.selectedListings = [];

	// private
	Listings.checkTheBox = function(item) {
		item.addClass('fa-check-square').removeClass('fa-square-o');
	};
	// private
	Listings.uncheckTheBox = function(item) {
		item.addClass('fa-square-o').removeClass('fa-check-square');
	};
	// private
	Listings.updateSelectedButton = function() {
		$('#selected-listings-dropdown').html(Listings.selectedListings.length + " Selected Listings <span class=\"caret\"></span>");
		if (Listings.selectedListings.length == 0) {
			$('#selected-listings-dropdown').addClass("disabled");
		} else {
			$('#selected-listings-dropdown').removeClass("disabled");
		}

		// update the hidden tag with the latest list of ids
		$('#residential_listing_listing_ids').val(Listings.selectedListings);
	};
	// private
	// if any individual listings get unchecked, then uncheck
	// the main toggle inside our th
	Listings.uncheckHeadToggle = function() {
		Listings.uncheckTheBox($('th > i'));
	};

	Listings.selectAllListings = function() {
		var isChecked = $(this).hasClass('fa-check-square');
		if (isChecked) {
			// uncheck all boxes, clear our list
			Listings.uncheckTheBox($(this));
			Listings.selectedListings = [];

			$('td > i').map(function() {
				if ($(this).hasClass('fa-check-square')) {
					Listings.uncheckTheBox($(this));
				}
			});
		} else {
			// check all boxes, fill our list
			Listings.checkTheBox($(this));
			Listings.selectedListings = $('tr').map(function() {
				return $(this).attr('data-id');
			}).get();

			$('td > i').map(function() {
				if ($(this).hasClass('fa-square-o')) {
					Listings.checkTheBox($(this));
				}
			});
		}

		Listings.updateSelectedButton();
	};

	Listings.toggleListingSelection = function() {
		// TODO: cap the max # of listings you can select?
		var isChecked = $(this).hasClass('fa-check-square');
		var listing_id = $(this).parent().parent().attr('data-id');

		if (isChecked) {
			//$(this).addClass('fa-square-o').removeClass('fa-check-square');
			Listings.uncheckTheBox($(this));
			Listings.selectedListings.splice(Listings.selectedListings.indexOf(listing_id), 1);
			Listings.uncheckHeadToggle();
		} else {
			//$(this).addClass('fa-check-square').removeClass('fa-square-o');
			Listings.checkTheBox($(this));
			Listings.selectedListings.push(listing_id);
		}

		Listings.updateSelectedButton();
	};

	Listings.sendMessage = function(e) {
		Listings.hideSpinner();
		$('#email_modal_recipients').val('');
		//$('#residential_listing_title').val('');
		$('#email_modal_message').val('');
		e.preventDefault();
	};

	Listings.assignPrimaryAgent = function(e) {
		$.ajax({
			url: $('#section-name').attr('data-name') + '/assign_modal',
	    data: {
        listing_ids: Listings.selectedListings,
	    },
	    dataType: 'script'
	  });
	};

	Listings.unassignPrimaryAgent = function(e) {
		$.ajax({
			url: $('#section-name').attr('data-name') + '/unassign_modal',
	    data: {
        listing_ids: Listings.selectedListings,
	    },
	    dataType: 'script'
	  });
	};

	Listings.indexMenuActions = {
		'send': function() {
			//console.log('sending!');
			var params = 'listing_ids=' + Listings.selectedListings.join(",");
			var section_name = $('#section-name').attr('data-name');
			window.location.href = '/' + section_name + '/print_list?' + params;
		},
		'listingsSheet': function() {
			//console.log('sheet!');
			var params = 'listing_ids=' + Listings.selectedListings.join(",");
			var section_name = $('#section-name').attr('data-name');
			window.location.href = '/' + section_name + '/print_public?' + params;
		},
		'internalListingsSheet': function() {
			var params = 'listing_ids=' + Listings.selectedListings.join(",");
			var section_name = $('#section-name').attr('data-name');
			window.location.href = '/' + section_name + '/print_private?' + params;
		}
	};

	Listings.showSpinner = function() {
		$('.listings-spinner-desktop').show();
	};

	Listings.hideSpinner = function() {
		$('.listings-spinner-desktop').hide();
	};
})();

