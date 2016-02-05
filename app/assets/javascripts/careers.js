Careers = {};

(function() {
	Careers.sortOnColumnClick = function() {
		$('#careers .th-sortable').click(function(e) {
			Common.sortOnColumnClick($(this), Careers.doSearch);
		});
	};

	// for searching on the index page
	Careers.doSearch = function (sortByCol, sortDirection) {
		var search_path = $('#careers-search-filters').attr('data-search-path');

	  Forms.showSpinner();

	  if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
      name: $('#careers #name').val(),
      submitted_date: $('#careers #submitted_date').val(),
      status: $('#careers #status').val(),
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
   //      name: $('#careers #name').val(),
   //      submitted_date: $('#careers #submitted_date').val(),
   //      status: $('#careers #status').val(),
   //      sort_by: sort_by_col,
   //      direction: sort_direction,
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
	Careers.timer;

	Careers.clearTimer = function() {
		clearTimeout(Careers.timer);
	};

	Careers.throttledSearch = function () {
		//clear any interval on key up
		if (Careers.timer) {
		  clearTimeout(Careers.timer);
		}
	  Careers.timer = setTimeout(Careers.doSearch, 500);
	};

	Careers.initialize = function() {
		if (!$('#careers').length) {
			return;
		}

		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		});
		Forms.hideSpinner();

		// main index table
		Careers.sortOnColumnClick();
		Common.markSortingColumn();
		if (Common.getSearchParam('sort_by') === '') {
			Common.markSortingColumnByElem($('th[data-sort="created_at"]'), 'desc')
		}

		$('.close').click(function() {
			Forms.hideSpinner();
		});

		// index filtering
		$('#careers input').keydown(Forms.preventEnter);
		$('#careers #name').bind('railsAutocomplete.select', Careers.throttledSearch);
		$('#careers #name').change(Careers.throttledSearch);
	  $('#careers #status').change(Careers.throttledSearch);
	  $('#careers #submitted_date').blur(Careers.throttledSearch);

		// index page - selecting listings menu dropdown
		$('#careers #emailListings').click(Forms.sendMessage);
		$('#careers #deleteMultiple').click(Forms.deleteMultiple);

		$('#careers tbody').on('click', 'i', Forms.toggleListingSelection);
		$('#careers .select-all-listings').click(Forms.selectAllListings);
		$('#careers .selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Forms.indexMenuActions) Forms.indexMenuActions[action]();
		});
	};

})();

$(document).ready(Careers.initialize);
