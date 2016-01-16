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
        active_only: $('#landlords #listings_checkbox_active').prop('checked')
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
      active_only: $('#checkbox_active').prop('checked'),
      sort_by: sortByCol,
      direction: sortDirection,
    };

    var searchParams = [];
    for(var key in data) {
      if (data.hasOwnProperty(key) && data[key] && data[key].toLowerCase() !== 'any') {
        searchParams.push(key + "=" + data[key]);
      }
    }
    window.location.search = searchParams.join('&');

    // $.ajax({
    //   url: search_path,
    //   data: {
    //     filter: $('#filter').val(),
    //     active_only: $('#checkbox_active').prop('checked'),
    //     sort_by: sortByCol,
    //     direction: sortDirection,
    //   },
    //   dataType: "script",
    //   success: function(data) {
    //     //console.log('SUCCESS:', data.responseText);
    //     Landlords.hideSpinner();
    //   },
    //   error: function(data) {
    //     //console.log('ERROR:', data.responseText);
    //     Landlords.hideSpinner();
    //   }
    // });
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

  // any phone #'s listed in 'access info' on main index pg should
  // be automatically detected
  Landlords.detectPhoneNumbers = function () {
    //if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {

      var countrycodes = "1"
      var delimiters = "-|\\.|—|–|&nbsp;"
      var phonedef = "\\+?(?:(?:(?:" + countrycodes + ")(?:\\s|" + delimiters + ")?)?\\(?[2-9]\\d{2}\\)?(?:\\s|" + delimiters + ")?[2-9]\\d{2}(?:" + delimiters + ")?[0-9a-z]{4})"
      var spechars = new RegExp("([- \(\)\.:]|\\s|" + delimiters + ")","gi") //Special characters to be removed from the link
      var phonereg = new RegExp("((^|[^0-9])(href=[\"']tel:)?((?:" + phonedef + ")[\"'][^>]*?>)?(" + phonedef + ")($|[^0-9]))","gi")

      function ReplacePhoneNumbers(oldhtml) {
        //Created by Jon Meck at LunaMetrics.com - Version 1.0
        var newhtml = oldhtml.replace(/href=['"]callto:/gi,'href="tel:')
        newhtml = newhtml.replace(phonereg, function ($0, $1, $2, $3, $4, $5, $6) {
            if ($3) return $1;
            else if ($4) return $2+$4+$5+$6;
            else return $2+"<a href='tel:"+$5.replace(spechars,"")+"'>"+$5+"</a>"+$6; });
        return newhtml;
      }

      $('.js-ll-phone').map(function() {
        $(this).html(ReplacePhoneNumbers($(this).html()))
      });
    //}
  };

  Landlords.initialize = function() {
    if (!$('#landlords').length) {
      return;
    }

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

    $('#landlords .has-fee').click(Landlords.toggleFeeOptions);
    Landlords.toggleFeeOptions();

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
    $('#landlords #checkbox_active').click(Landlords.throttledSearch);
    $('#landlords #listings_checkbox_active').click(Landlords.filterListings);

    Landlords.detectPhoneNumbers();
  };
})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    Landlords.hideSpinner();
  }
});

$(document).ready(Landlords.initialize);
