Common = {};

(function() {
  Common.getURLParameterByName = function (name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
      results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
  }

  Common.onMobileDevice = function() {
    // does not include iPad
    return /Android|webOS|iPhone|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  }

  // any phone #'s listed in 'access info' on main index pg should
  // be automatically detected
  Common.detectPhoneNumbers = function () {
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

    $('.js-phoneNumber').map(function() {
      $(this).html(ReplacePhoneNumbers($(this).html()))
    });
  };

  Common.getSearchParam = function(paramName) {
    var idx = -1,
      startIdx = -1,
      endIdx = -1,
      searchStr = window.location.search,
      retVal = '';

    idx = searchStr.indexOf(paramName);
    if (idx > -1) {
      startIdx = searchStr.indexOf('=', idx+1);
      endIdx = searchStr.indexOf('&', idx+1);
      retVal = endIdx === -1 ? searchStr.slice(startIdx+1) : searchStr.slice(startIdx+1, endIdx);
    }

    return retVal;
  };

  Common.sortOnColumnClick = function(elem, callback) {
    var sortDirection = '',
        sortByCol = null;

    if (elem.hasClass('selected-sort')) {
      // switch sort order
      var i = $('.selected-sort i');
      if (i) {
        if (i.hasClass('glyphicon glyphicon-triangle-bottom')) {
          i.removeClass('glyphicon glyphicon-triangle-bottom').addClass('glyphicon glyphicon-triangle-top');
          sortDirection = 'asc';
        }
        else if (i.hasClass('glyphicon glyphicon-triangle-top')) {
          i.removeClass('glyphicon glyphicon-triangle-top').addClass('glyphicon glyphicon-triangle-bottom');
          sortDirection = 'desc';
        }
      }
    } else {
      // remove selection from old row
      $('.selected-sort').attr('data-direction', '');
      $('th i').remove(); // remove arrows
      $('.selected-sort').removeClass('selected-sort');
      // select new column
      elem.addClass('selected-sort').append(' <i class="glyphicon glyphicon-triangle-bottom"></i>');
      sortDirection = 'desc';
    }

    sortByCol = elem.attr('data-sort');
    elem.attr('data-direction', sortDirection);
    callback(sortByCol, sortDirection);
  };

  Common.markSortingColumnByElem = function(columnElem, direction) {
    if (direction === 'asc') {
      columnElem.addClass('selected-sort').append(' <i class="glyphicon glyphicon-triangle-top"></i>');
    } else {
      columnElem.addClass('selected-sort').append(' <i class="glyphicon glyphicon-triangle-bottom"></i>');
    }

    columnElem.attr('data-direction', direction);
  };

  // sets column sort UI from search params
  Common.markSortingColumn = function() {
    var searchStr = window.location.search,
        direction = '',
        sortByCol = '',
        columnElem = null,
        idx = -1,
        startIdx = -1,
        endIdx = -1;

    idx = searchStr.indexOf('sort_by');
    if (idx > -1) {
      startIdx = searchStr.indexOf('=', idx+1);
      endIdx = searchStr.indexOf('&', idx+1);
      sortByCol = endIdx === -1 ? searchStr.slice(startIdx+1) : searchStr.slice(startIdx+1, endIdx);
    }

    idx = searchStr.indexOf('direction');
    if (idx > -1) {
      startIdx = searchStr.indexOf('=', idx+1);
      endIdx = searchStr.indexOf('&', idx+1);
      direction = endIdx === -1 ? searchStr.slice(startIdx+1) : searchStr.slice(startIdx+1, endIdx);
    }

    columnElem = $('th[data-sort="' + sortByCol + '"]');
    Common.markSortingColumnByElem(columnElem, direction);
  };

})();
