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
    $('input').keydown(Company.preventEnter);
    $('#name').keyup(Company.throttledSearch);
  };

})();

$(document).ready(function() {
  if ($('.companies').length) {
    Company.initialize();
  }
});
