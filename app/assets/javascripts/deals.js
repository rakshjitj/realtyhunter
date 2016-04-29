Deals = {};

(function() {
  Deals.timer;

  Deals.sortOnColumnClick = function() {
    $('#deals .th-sortable').click(function(e) {
      Common.sortOnColumnClick($(this), Deals.doSearch);
    });
  };

  // for searching on the index page
  Deals.doSearch = function (sortByCol, sortDirection) {
    var search_path = $('#deals-search-filters').attr('data-search-path');

    Forms.showSpinner();

    if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
      address: $('#deals #address').val(),
      landlord_code: $('#deals #landlord_code').val(),
      closed_date_start: $('#deals #closed_date_start').val(),
      closed_date_end: $('#deals #closed_date_end').val(),
      state: $('#deals #state').val(),
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
  };

  Deals.clearTimer = function() {
    clearTimeout(Deals.timer);
  };

  Deals.throttledSearch = function () {
    //clear any interval on key up
    if (Deals.timer) {
      clearTimeout(Deals.timer);
    }
    Deals.timer = setTimeout(Deals.doSearch, 500);
  };

  Deals.updateUnits = function() {
    $.ajax({
      url: "/deals/get_units",
      data: {
        building_id: $('#deals #deal_building_id').val()
      },
      dataType: "script",
    });
  };

  Deals.initIndex = function() {
    Forms.hideSpinner();

    // main index table
    Deals.sortOnColumnClick();
    Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="closed_date"]'), 'desc')
    }

    $('.close').click(function() {
      Forms.hideSpinner();
    });

    // index filtering
    $('#deals input').keydown(Forms.preventEnter);
    $('#deals #address').bind('railsAutocomplete.select', Deals.throttledSearch);
    $('#deals #address').change(Deals.throttledSearch);
    $('#deals #landlord_code').bind('railsAutocomplete.select', Deals.throttledSearch);
    $('#deals #landlord_code').change(Deals.throttledSearch);
    $('#deals #closed_date_start').blur(Deals.throttledSearch);
    $('#deals #closed_date_end').blur(Deals.throttledSearch);
    $('#deals #state').change(Deals.throttledSearch);

    // edit
    if ($('#deals #deal_building_id').length) {
      $('#deals #deal_building_id').change(Deals.updateUnits);
    }
  };

  Deals.ready = function () {
    var editPage = $('.deals.edit').length;
    var newPage = $('.deals.new').length;
    var indexPage = $('.deals.index').length;
    var showPage = $('.deals.show').length;
    // new and edit pages both render the same form template, so init them using the same code
    if (editPage || newPage) {
      // Deals.initEditor();
    } else if (indexPage) {
      Deals.initIndex();
    } // else if (showPage) {
    //   Deals.initShow();
    // }
  };
})();

$(document).on('ready page:load', Deals.ready);

$(document).on('page:restore', Deals.ready);

