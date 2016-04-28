Offices = {};

(function() {
  Offices.init = function () {
    if ($('.offices.edit').length) {
      var office_address = $('#map-canvas').attr('data-address') ? $('#map-canvas').attr('data-address') : 'New York, NY, USA';
      $(".autocomplete-input").geocomplete({
        map: "#map-canvas",
        location: office_address,
        details: ".details"
      }).bind("geocode:result", function () {
        // console.log(result);
      }).bind("geocode:error", function (event, result) {
        // console.log("[ERROR]: " + result);
      });
    }
  };

})();

$(document).on('ready page:load', Offices.init);

$(document).on('page:restore', Offices.init);

