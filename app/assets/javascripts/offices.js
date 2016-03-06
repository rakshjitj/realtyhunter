Offices = {};

(function() {
  Offices.initIndex = function() {
    $(".map-container").geocomplete({
      map: "#map-canvas",
      location: "<%= @office.formatted_street_address %>" ,
      details: ".details"
    }).bind("geocode:result", function(event, result){
        //console.log(result);
    }).bind("geocode:error", function(event, result){
        //console.log("[ERROR]: " + result);
    });
  };

  Offices.initEdit = function() {
    var office_address = $('#map-canvas').attr('data-address') ? $('#map-canvas').attr('data-address') : 'New York, NY, USA';
    $(".autocomplete-input").geocomplete({
      map: "#map-canvas",
      location: office_address,
      details: ".details"
    }).bind("geocode:result", function(event, result){
      //console.log(result);
    }).bind("geocode:error", function(event, result){
      //console.log("[ERROR]: " + result);
    });
  };

})();

$(document).ready(function() {
  if ($('.offices.show').length) {
    Offices.initIndex();
  }

  if ($('.offices.edit').length) {
    Offices.initEdit();
  }
});
