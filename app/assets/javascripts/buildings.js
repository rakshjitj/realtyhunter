(function() {

  function filterListings(event) {
  	var search_path = $('#listings').attr('data-search-path');
  	console.log(search_path);

    $.ajax({
      url: search_path,
      data: {
        active_only: $('#listings_checkbox_active').prop('checked')
      },
      dataType: "script"
    }).fail(function() {
      //console.log("[FAILED] search update failed");
    });
  };

  function filterBuildings(event) {
  	var search_path = $('#search-filters').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        filter: $('#filter').val(),
        active_only: $('#checkbox_active').prop('checked')
      },
      dataType: "script"
    }).fail(function() {
      //console.log("[FAILED] search update failed");
    });
  };

  // search as user types
  var timer;
  function throttledBldgSearch() {
    clearInterval(timer);  //clear any interval on key up
    timer = setTimeout(filterBuildings, 500);
  };

  // change enter key to tab
  function preventEnter(event) {
    if (event.keyCode == 13) {
      $('#checkbox_active').focus();
      return false;
    }
  };

  function removeBldgImage(id, bldg_id) {
  	// make a DELETE ajax request to delete the file
  	$.ajax({
  		type: 'DELETE',
  		url: '/buildings/' + bldg_id + '/images/' + id,
  		success: function(data){
  			console.log(data.message);
  			$.getScript('/buildings/' + bldg_id + '/refresh_images')
  		},
  		error: function(data) {
  			console.log('ERROR:', data);
  		}
  	});
  };

  function set_positions() {
    // loop through and give each task a data-pos
    // attribute that holds its position in the DOM
    $('.img-thumbnail').each(function(i) {
        $(this).attr("data-pos", i+1);
    });
  };

  $(document).ready(function(){
    // search filters
    $('#filter').keydown(preventEnter);
    $('#filter').keyup(throttledBldgSearch);
    // toggle between active and inactive units
    $('#checkbox_active').click(filterBuildings);
    $('#listings_checkbox_active').click(filterListings);

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
  			removeBldgImage(id, bldg_id);
  			file.previewElement.remove();
  		}
  	});

  	$('.delete-bldg-img').click(function(event) {
  		event.preventDefault();
  		var id = $(this).attr('data-id');
  		var bldg_id = $(this).attr('data-bldg-id');
  		console.log(id, bldg_id);
  		removeBldgImage(id, bldg_id);
  	});

  	$('.carousel-indicators > li:first-child').addClass('active');
  	$('.carousel-inner > .item:first-child').addClass('active')

  	// call set_positions function
    set_positions();

    // call sortable on our div with the sortable class
    $('.sortable').sortable({
  		forcePlaceholderSize: true,
  		placeholderClass: 'col col-xs-2 border border-maroon',
  		dragImage: null
    });

    // after the order changes
    $('.sortable').sortable().bind('sortupdate', function(e, ui) {
      // array to store new order
      updated_order = []
      // set the updated positions
      set_positions();
  			
      // populate the updated_order array with the new task positions
      $('.img-thumbnail').each(function(i){
        updated_order.push({ id: $(this).data('id'), position: i+1 });
      });
  			console.log(updated_order);
      // send the updated order via ajax
      $.ajax({
        type: "PUT",
        url: '/buildings/' + "<%= @building.id %>" + '/images/sort',
        data: { order: updated_order }
      });
    });
  	
  });// end document ready

})();