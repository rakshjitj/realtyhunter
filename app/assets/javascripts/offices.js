Offices = {};

(function() {
  Offices.init = function() {
    var office_address = $('#map-canvas').attr('data-address') ? $('#map-canvas').attr('data-address') : 'New York, NY, USA';
    $(".autocomplete-input").geocomplete({
      map: "#map-canvas",
      location: office_address,
      details: ".details"
    }).bind("geocode:result", function(event, result) {
      // console.log(result);
    }).bind("geocode:error", function(event, result) {
      console.log("[ERROR]: " + result);
    });
  };

})();

$(document).ready(function() {
  if ($('.offices.edit').length) {
    Offices.init();
  }
});
