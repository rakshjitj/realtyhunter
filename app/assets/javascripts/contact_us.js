ContactUs = {};

(function() {
	ContactUs.sortOnColumnClick = function() {
		$('#contact-us .th-sortable').click(function(e) {
			Common.sortOnColumnClick($(this), ContactUs.doSearch);
		});
	};

	// for searching on the index page
	ContactUs.doSearch = function (sortByCol, sortDirection) {
		//console.log(sort_by_col, sort_direction);
		var search_path = $('#contact-us-search-filters').attr('data-search-path');

	  Forms.showSpinner();

	  if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
      name: $('#contact-us #name').val(),
      submitted_date: $('#contact-us #submitted_date').val(),
      status: $('#contact-us #status').val(),
      min_price: $('#contact-us #min_price').val(),
      max_price: $('#contact-us #max_price').val(),
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
   //      name: $('#contact-us #name').val(),
   //      submitted_date: $('#contact-us #submitted_date').val(),
   //      status: $('#contact-us #status').val(),
   //      min_price: $('#contact-us #min_price').val(),
   //      max_price: $('#contact-us #max_price').val(),
   //      sort_by: sortByCol,
   //      direction: sortDirection,
	  //   },
	  //   dataType: 'script',
	  //   success: function(data) {
	  //   	Forms.hideSpinner();
			// },
			// error: function(data) {
			// 	Forms.hideSpinner();
			// }
	  // });
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
		if (!$('#contact-us').length) {
			return;
		}

		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		});
		Forms.hideSpinner();

		// main index table
		ContactUs.sortOnColumnClick();
		Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="created_at"]'), 'desc')
    }

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

		Common.detectPhoneNumbers();
	};

})();

$(document).ready(ContactUs.initialize);
