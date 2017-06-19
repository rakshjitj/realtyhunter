Partner = {};

(function() {
  Partner.sortOnColumnClick = function() {
    $('#partner .th-sortable').click(function(e) {
      Common.sortOnColumnClick($(this), Partner.doSearch);
    });
  };

  // for searching on the index page
  Partner.doSearch = function (sortByCol, sortDirection) {
    var search_path = $('#partner-search-filters').attr('data-search-path');

    Forms.showSpinner();

    if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
      name: $('#partner #name').val(),
      submitted_date: $('#partner #submitted_date').val(),
      status: $('#partner #status').val(),
      address_street_address: $('#partner #address_street_address').val(),
      number_of_bedrooms: $('#partner #number_of_bedrooms').val(),
      move_in_date: $('#partner #move_in_date').val(),
      renovated: $('#partner #renovated').val(),
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
   //      name: $('#partner #name').val(),
   //      submitted_date: $('#partner #submitted_date').val(),
   //      status: $('#partner #status').val(),
   //      address_street_address: $('#partner #address_street_address').val(),
   //      number_of_bedrooms: $('#partner #number_of_bedrooms').val(),
   //      move_in_date: $('#partner #move_in_date').val(),
   //      renovated: $('#partner #renovated').val(),
   //      sort_by: sortByCol,
   //      direction: sortDirection,
    //   },
    //   dataType: 'script',
    //   success: function(data) {
    //    Forms.hideSpinner();
      // },
      // error: function(data) {
      //  Forms.hideSpinner();
      // }
    // });
  };

  // search as user types
  Partner.timer;

  Partner.clearTimer = function() {
    clearTimeout(Partner.timer);
  };

  Partner.throttledSearch = function () {
    //clear any interval on key up
    if (Partner.timer) {
      clearTimeout(Partner.timer);
    }
    Partner.timer = setTimeout(Partner.doSearch, 500);
  };

  Partner.initialize = function() {
    if (!$('#partner').length) {
      return;
    }

    Forms.hideSpinner();
    Forms.selectedEntries = [];
    Forms.selectedRoommateEmails = [];

    // main index table
    Partner.sortOnColumnClick();
    Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="created_at"]'), 'desc')
    }

    $('.close').click(function() {
      Forms.hideSpinner();
    });

    // index filtering
    $('#partner input').keydown(Forms.preventEnter);
    $('#partner #name').bind('railsAutocomplete.select', Partner.throttledSearch);
    $('#partner #name').change(Partner.throttledSearch);
    $('#partner #status').change(Partner.throttledSearch);
    $('#partner #address_street_address').change(Partner.throttledSearch);
    $('#partner #address_street_address').bind('railsAutocomplete.select', Partner.throttledSearch);
    $('#partner #number_of_bedrooms').change(Partner.throttledSearch);
    $('#partner #move_in_date').blur(Partner.throttledSearch);
    $('#partner #submitted_date').blur(Partner.throttledSearch);
    $('#partner #renovated').change(Partner.throttledSearch);

    // index page - selecting listings menu dropdown
    $('#partner #emailListings').click(Forms.sendMessage);
    $('#partner #deleteMultiple').click(Forms.deleteMultiple);

    $('#partner tbody').off('click', 'i', Forms.toggleListingSelection);
    $('#partner tbody').on('click', 'i', Forms.toggleListingSelection);
    $('#partner .select-all-listings').click(Forms.selectAllListings);
    $('#partner .selected-listings-menu').on('click', 'a', function() {
      var action = $(this).data('action');
      if (action in Forms.indexMenuActions) Forms.indexMenuActions[action]();
    });
  };

})();

document.addEventListener('turbolinks:load', Partner.initialize);
