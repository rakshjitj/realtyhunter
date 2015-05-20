// Plugin taken from https://ubilabs.github.io/geocomplete/
// Included under /vendor

$( document ).ready(function() {
    //console.log( "autocomplete plugin ready!" );

    $(".autocomplete-input").geocomplete({
    	map: "#map_canvas",
    	location: "New York, NY",
    	details: ".details",
    }).bind("geocode:result", function(event, result){
        if (this.value = "New York, NY") {
            this.value = '';
            //console.log(result);
        }
    }).bind("geocode:error", function(event, result){
        //console.log("[ERROR]: " + result);
    });

});
