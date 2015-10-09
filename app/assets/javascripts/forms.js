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

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
  	Forms.hideSpinner();
  }
});
