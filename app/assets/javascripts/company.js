Company = {};

(function() {
  Company.timer;

  Company.doSearch(event) {
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
    clearInterval(timer);  //clear any interval on key up
    timer = setTimeout(doSearch, 500);
  };

  // change enter key to tab
  Company.preventEnter = function(event) {
    if (event.keyCode == 13) {
      return false;
    }
  };

  //call when typing or enter or focus leaving
  Company.initialize = function() {
    $('input').keydown(preventEnter);
    $('#name').keyup(throttledSearch);
  };

})();

$(document).ready(function() {
  if ($('.companies').length) {
    Company.initialize();
  }
});
