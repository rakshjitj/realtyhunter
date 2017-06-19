Offices = {};

(function() {
  Offices.init = function () {
    if ($('.offices.edit').length || $('.offices.new').length) {
      var office_address = $('#map-canvas').attr('data-address') ? $('#map-canvas').attr('data-address') : 'New York, NY, USA';
      $(".autocomplete-input").geocomplete({
        map: "#map-canvas",
        location: office_address,
        details: ".details"
      }).bind("geocode:result", function () {
      }).bind("geocode:error", function (event, result) {
      });
    }
  };

})();

document.addEventListener('turbolinks:load', Offices.init);

