Landlords = {};

(function() {

  Landlords.showSpinner = function() {
    $('#landlords .ll-spinner-desktop').show();
  };

  Landlords.hideSpinner = function() {
    $('#landlords .ll-spinner-desktop').hide();
  };

  Landlords.filterListings = function(event) {
    var search_path = $('#listings').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        status_listings: $('#landlords #status_listings').val(),
      },
      dataType: "script",
      success: function(data) {
        Landlords.hideSpinner();
      },
      error: function(data) {
        Landlords.hideSpinner();
      }
    });
  };

  Landlords.doSearch = function(sortByCol, sortDirection) {
    var search_path = $('#landlord-search-filters').attr('data-search-path');
    Landlords.showSpinner();

    if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
      filter: $('#filter').val(),
      status: $('#status').val(),
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

  Landlords.sortOnColumnClick = function() {
    $('#landlords .th-sortable').click(function(e) {
      Common.sortOnColumnClick($(this), Landlords.doSearch);
    });
  };

  // search as user types
  Landlords.timer;
  Landlords.throttledSearch = function() {
    Landlords.showSpinner();

    clearTimeout(Landlords.timer); // clear any interval on key up
    Landlords.timer = setTimeout(Landlords.doSearch, 500);
  };

  // change enter key to tab
  Landlords.preventEnter = function(event) {
    if (event.keyCode == 13) {
      $('#checkbox_active').focus();
      return false;
    }
  };

  Landlords.toggleFeeOptions = function(event) {
    var isChecked = $('#landlords .has-fee').prop('checked');
    if (isChecked) {
      $('#landlords .show-op').addClass('hide');
      $('#landlords .show-tp').removeClass('hide');
    } else {
      $('#landlords .show-op').removeClass('hide');
      $('#landlords .show-tp').addClass('hide');
    }
  };

  Landlords.initEditor = function() {
    $('#landlords .has-fee').click(Landlords.toggleFeeOptions);
    Landlords.toggleFeeOptions();
  }

  Landlords.initIndex = function() {
    document.addEventListener("page:restore", function() {
      Landlords.hideSpinner();
    });
    Landlords.hideSpinner();
    $('#landlords a').click(function() {
      Landlords.showSpinner();
    });

    // main index table
    Landlords.sortOnColumnClick();
    Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="name"]'), 'asc')
    }

    var bldg_address = $('#map_canvas').attr('data-address') ? $('#map_canvas').attr('data-address') : 'New York, NY, USA';

    $(".autocomplete-input").geocomplete({
      map: "#map_canvas",
      location: bldg_address,
      details: ".details"
    }).bind("geocode:result", function(event, result){
      if (this.value == "New York, NY, USA") {
        this.value = '';
      }
    }).bind("geocode:error", function(event, result){
      console.log(bldg_address, "[ERROR]: " + result);
    });

    $('#landlords #filter').bind('railsAutocomplete.select', Landlords.throttledSearch);
    $('#landlords #filter').keydown(Landlords.preventEnter);
    $('#landlords #filter').change(Landlords.throttledSearch);
    $('#landlords #status').change(Landlords.throttledSearch);
    $('#landlords #status_listings').change(Landlords.filterListings);
  }

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    Landlords.hideSpinner();
  }
});

$(document).ready(function () {
  var url = window.location.pathname;
  var landlords = url.indexOf('landlords') > -1;
  var editPage = url.indexOf('edit') > -1;
  var newPage = url.indexOf('new') > -1;
  if (landlords) {
    // new and edit pages both render the same form template, so init them using the same code
    if (editPage || newPage) {
      Landlords.initEditor();
    } else {
      Landlords.initIndex();
    }
  }
});
