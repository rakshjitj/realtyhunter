Buildings = {};

(function() {

  Buildings.filterListings = function(event) {
  	var search_path = $('#listings').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        active_only: $('#listings_checkbox_active').prop('checked')
      },
      dataType: "script",
    }).fail(function() {
      //console.log("[FAILED] search listings update failed");
    });
  };

  Buildings.filterBuildings = function(event) {
  	var search_path = $('#search-filters').attr('data-search-path');
    //console.log("[" + search_path + "] BUILDINGS searching for " + $('#filter').val(), $('#checkbox_active').prop('checked'));
    // for whatever reason, we need to set dataType to json here in order
    // to trigger the call as js.
    $.ajax({
      url: search_path,
      data: {
        filter: $('#buildings #filter').val(),
        active_only: $('#buildings #checkbox_active').prop('checked')
      },
      dataType: "script"
    }).fail(function(e) {
      //console.log("[FAILED] search bldgs update failed", e);
    });
  };

  // search as user types
  Buildings.timer;
  Buildings.throttledBldgSearch = function() {
    // only accept letter/number keys as search input
    // var charTyped = String.fromCharCode(e.which);
    // if (/[a-z\d]/i.test(charTyped)) {
    //     console.log("Letter or number typed: " + charTyped);
    // } else {
    //   return;
    // }
    clearTimeout(Buildings.timer);  //clear any interval on key up
    Buildings.timer = setTimeout(Buildings.filterBuildings, 500);
  };

  // change enter key to tab
  Buildings.preventEnter = function(event) {
    if (event.keyCode == 13) {
      $('#buildings #checkbox_active').focus();
      return false;
    }
  };

  Buildings.setPositions = function() {
    // loop through and give each task a data-pos
    // attribute that holds its position in the DOM
    $('#buildings .img-thumbnail').each(function(i) {
        $(this).attr("data-pos", i+1);
    });
  };

  Buildings.removeBldgImage = function (id, building_id) {
    // make a DELETE ajax request to delete the file
    $.ajax({
      type: 'DELETE',
      url: '/buildings/' + building_id + '/images/' + id,
      success: function(data){
        //console.log(data.message);
        $.getScript('/buildings/' + building_id + '/refresh_images')
      },
      error: function(data) {
        //console.log('ERROR:', data);
      }
    });
  };

  Buildings.makeSortable = function() {
    // call sortable on our div with the sortable class
    $('#buildings .sortable').sortable({
      forcePlaceholderSize: true,
      placeholderClass: 'col col-xs-2 border border-maroon',
      dragImage: null
    });
  };

  Buildings.updateRemoveImgLinks = function() {
    $('#buildings .delete-bldg-img').click(function(event) {
      event.preventDefault();
      var id = $(this).attr('data-id');
      var bldg_id = $(this).attr('data-bldg-id');
      console.log(id, bldg_id);
      Buildings.removeBldgImage(id, bldg_id);
    });
  };

  Buildings.initialize = function() {
    // // change all date input fields to auto-open the calendar
    // $('.datepicker').datetimepicker({
    //   viewMode: 'days',
    //   format: 'MM/DD/YYYY',
    //   allowInputToggle: true
    // });
    
    // search filters
    $('#buildings #filter').keydown(Buildings.preventEnter);
    $('#buildings #filter').change(Buildings.throttledBldgSearch);
    // toggle between active and inactive units
    $('#buildings #checkbox_active').click(Buildings.filterBuildings);
    $('#buildings #listings_checkbox_active').click(Buildings.filterListings);

    var bldg_address = $('#map_canvas').attr('data-address') ? $('#map_canvas').attr('data-address') : 'New York, NY, USA';
    // google maps
    $("#bldg_panel").geocomplete({
    	map: "#map_canvas",
    	location: bldg_address,
    	details: ".details"
    }).bind("geocode:result", function(event, result){
      //console.log(result);
    }).bind("geocode:error", function(event, result){
      //console.log("[ERROR]: " + result);
    });

  	$(".autocomplete-input").geocomplete({
      map: "#map_canvas",
      location: bldg_address,
      details: ".details"
    }).bind("geocode:result", function(event, result){
      if (this.value == "New York, NY, USA") {
        this.value = '';
      }
    }).bind("geocode:error", function(event, result){
    	//console.log("[ERROR]: " + result);
    });
  		
  	// editing photos

  	// disable auto discover
  	Dropzone.autoDiscover = false;
   
  	// grap our upload form by its id
  	$("#building-dropzone").dropzone({
  		// restrict image size to a maximum 1MB
  		//maxFilesize: 4,
  		//paramName: "upload[image]",
  		// show remove links on each image upload
  		addRemoveLinks: true,
  		// if the upload was successful
  		success: function(file, response){
  			// find the remove button link of the uploaded file and give it an id
  			// based of the fileID response from the server
  			$(file.previewTemplate).find('.dz-remove').attr('id', response.fileID);
  			$(file.previewTemplate).find('.dz-remove').attr('bldg_id', response.bldgID);
  			// add the dz-success class (the green tick sign)
  			$(file.previewElement).addClass("dz-success");
  			$.getScript('/buildings/' + response.bldgID + '/refresh_images')
  			file.previewElement.remove();
  		},
  		//when the remove button is clicked
  		removedfile: function(file){
  			// grap the id of the uploaded file we set earlier
  			var id = $(file.previewTemplate).find('.dz-remove').attr('id'); 
  			var bldg_id = $(file.previewTemplate).find('.dz-remove').attr('bldg_id');
  			Buildings.removeBldgImage(id, bldg_id);
  			file.previewElement.remove();
  		}
  	});

  	Buildings.updateRemoveImgLinks();

  	$('.carousel-indicators > li:first-child').addClass('active');
  	$('.carousel-inner > .item:first-child').addClass('active')

    Buildings.setPositions();
    Buildings.makeSortable();

    // after the order changes
    $('#buildings .sortable').sortable().bind('sortupdate', function(e, ui) {
      // array to store new order
      updated_order = []
      // set the updated positions
      Buildings.setPositions();
  			
      // populate the updated_order array with the new task positions
      $('#buildings .img-thumbnail').each(function(i){
        updated_order.push({ id: $(this).data('id'), position: i+1 });
      });
  		console.log(updated_order);
      
      // send the updated order via ajax
      var bldg_id = $('#buildings').attr('data-bldg-id');
      $.ajax({
        type: "PUT",
        url: '/buildings/' + bldg_id + '/images/sort',
        data: { order: updated_order }
      });
    });
  	
  };// end initialize

})();

$(document).ready(Buildings.initialize);