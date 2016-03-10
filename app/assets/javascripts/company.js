Company = {};

(function() {
  Company.timer;

  Company.doSearch = function(event) {
    $.ajax({
      url: "<%= filter_companies_path %>",
      data: {
        search_params: {
          name: $('#name').val()
        }
      },
      dataType: "script"
    });
  };

  // search as user types
  Company.throttledSearch = function() {
    clearInterval(Company.timer);  //clear any interval on key up
    timer = setTimeout(Company.doSearch, 500);
  };

  // change enter key to tab
  Company.preventEnter = function(event) {
    if (event.keyCode == 13) {
      return false;
    }
  };

  //call when typing or enter or focus leaving
  Company.initialize = function() {
    if ($('.companies').length) {
      $('input').keydown(Company.preventEnter);
      $('#name').keyup(Company.throttledSearch);
    }
  };

})();

$(document).on('ready page:load', Company.initialize);

$(document).on('page:restore', Company.initialize);
