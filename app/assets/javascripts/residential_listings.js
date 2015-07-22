ResidentialListings = {};

// TODO: break this up by controller action

(function() {
	// for searching on the index page
	ResidentialListings.doSearch = function (event) {
		//console.log('PERFORMING SEARCH');
		// sanitize invalid input before submitting
	  if ($('#residential #neighborhood_ids').val() == "{:id=>\"neighborhood_ids\"}") {
	    $('#residential #neighborhood_ids').val('');
	  }
	  if ($('#residential #building_feature_ids').val() == "{:id=>\"building_feature_ids\"}") {
	    $('#residential #building_feature_ids').val('');
	  }
	  if ($('#residential #unit_feature_ids').val() == "{:id=>\"unit_feature_ids\"}") {
	    $('#residential #unit_feature_ids').val('');
	  }

	  var search_path = $('#res-search-filters').attr('data-search-path');
	  $.ajax({
	    url: search_path,
	    data: {
        address: $('#residential #address').val(),
        unit: $('#residential #unit').val(),
        rent_min: $('#residential #rent_min').val(),
        rent_max: $('#residential #rent_max').val(),
        bed_min: $('#residential #bed_min').val(),
        bed_max: $('#residential #bed_max').val(),
        bath_min: $('#residential #bath_min').val(),
        bath_max: $('#residential #bath_max').val(),
        landlord: $('#residential #landlord').val(),
        pet_policy_shorthand: $('#residential #pet_policy_shorthand').val(),
        available_starting: $('#residential #available_starting').val(),
        available_before: $('#residential #available_before').val(),
        status: $('#residential #status').val(),
        features: $('#residential #features').val(),
        has_fee: $('#residential #has_fee').val(),
        neighborhood_ids: $('#residential #neighborhood_ids').val(),
        unit_feature_ids: $('#residential #unit_feature_ids').val(),
        building_feature_ids: $('#residential #building_feature_ids').val(),
	    },
	    dataType: 'script',
	    success: function(data) {
	    	//console.log('SUCCESS:', data.responseText);
			},
			error: function(data) {
				//console.log('ERROR:', data.responseText);
			}
	  });
	};

	ResidentialListings.removeUnitFeature = function (event) {
  	event.preventDefault();
	  var feature_id = $(this).attr('data-id');
  	var idx = $('#residential #unit_feature_ids').val().indexOf(feature_id);
  	//console.log(feature_id, idx, feature_id.length, $('#unit_feature_ids').val());
  	$('#residential #unit_feature_ids').val( $('#residential #unit_feature_ids').val().replace(feature_id, '') );
  	//console.log('new val is', $('#unit_feature_ids').val() );
  	$(this).remove();
  	ResidentialListings.throttledSearch();
  };

  ResidentialListings.removeBuildingFeature = function (event) {
  	event.preventDefault();
	  var feature_id = $(this).attr('data-id');
  	var idx = $('#residential #building_feature_ids').val().indexOf(feature_id);
  	$('#residential #building_feature_ids').val( $('#residential #building_feature_ids').val().replace(feature_id, '') );
  	$(this).remove();
  	ResidentialListings.throttledSearch();
  };

  ResidentialListings.removeNeighborhood = function (event) {
  	event.preventDefault();
	  var feature_id = $(this).attr('data-id');
  	var idx = $('#residential #neighborhood_ids').val().indexOf(feature_id);
  	$('#residential #neighborhood_ids').val( $('#residential #neighborhood_ids').val().replace(feature_id, '') );
  	$(this).remove();
  	ResidentialListings.throttledSearch();
  };

	// search as user types
	ResidentialListings.timer;

	ResidentialListings.throttledSearch = function () {
		console.log('throttling?');
		//clear any interval on key up
		if (ResidentialListings.timer) {
			console.log('yes, clearing');
		  clearTimeout(ResidentialListings.timer);
		}
		// if (jqXHR && jqXHR.abort) { 
		// 	jqXHR.abort(); 
		// }
	  ResidentialListings.timer = setTimeout(ResidentialListings.doSearch, 500);
	};

	// change enter key to tab
	ResidentialListings.preventEnter = function (event) {
	  if (event.keyCode == 13) {
	    //$('#checkbox_active').focus();
	    return false;
	  }
	};

	ResidentialListings.removeImage = function (id, unit_id) {
		// make a DELETE ajax request to delete the file
		$.ajax({
			type: 'DELETE',
			url: '/residential_listings/' + unit_id + '/unit_images/' + id,
			success: function(data){
				//console.log(data.message);
				$.getScript('/residential_listings/' + unit_id + '/refresh_images')
			},
			error: function(data) {
				//console.log('ERROR:', data);
			}
		});
	};

	// for giant google map
	ResidentialListings.buildContentString = function (key, info) {
	  var contentString = '<strong>' + key + '</strong><hr />';
	  for (var i=0; i<info['units'].length; i++) {
	    contentString += '<a href="/residential_listings/' + info['units'][i].id + '">#' + info['units'][i].building_unit + '</a>: ' + info['units'][i].beds + ' beds / ' 
	      + info['units'][i].baths + ' baths $' + info['units'][i].rent + '<br />';
	    if (i == 5) {
	      contentString += '<a href="/residential_listings?building_id=' + info['building_id'] + '">View more...</a>';
	      break;
	    }
	  }
	  return contentString;
	};

	ResidentialListings.updateOverviewMap = function (in_data) {
		// for displaying the map points on the index page
		if ($('#big-map').length > 0) {
			var mapOptions = {
		    center: { lat: 40.6739591, lng: -73.9570342},
		    zoom: 12
		  };
		  var map = new google.maps.Map(document.getElementById('big-map'), mapOptions);
		  var dataPoints;
		  // if updating from an ajax call, in_data will hava content.
		  // we load data from a data attribute on page load, but that remains cached forever -
		  // it will not update with subsequent ajax calls.
		  if (in_data) {
		  	dataPoints = JSON.parse(in_data);
		  } else {
		  	dataPoints = JSON.parse($('#big-map').attr('data-map-points'));
		  }

			var infoWindow;
		  Object.keys(dataPoints).forEach(function(key, index) {
		    // draw each marker + load with data
		    var info = dataPoints[key];
		    var myLatlng = new google.maps.LatLng(info.lat, info.lng);
		    var marker = new google.maps.Marker({
		      map:map,
		      animation: google.maps.Animation.DROP,
		      position: myLatlng,
		    });
		    google.maps.event.addListener(marker, 'click', function() {
		    	if (infoWindow) {
		    		infoWindow.close();
		    	}
		    	var content = ResidentialListings.buildContentString(key, info);
		    	infoWindow = new google.maps.InfoWindow({
			    	content: content
			    });
		      infoWindow.open(map, marker);
		    });
			});
		}
	};

	ResidentialListings.toggleFeeOptions = function(event) {
		var isChecked = $('#residential .has-fee').prop('checked');
		if (isChecked) {
			$('#residential .show-op').addClass('hide');
			$('#residential .show-tp').removeClass('hide');
		} else {
			$('#residential .show-op').removeClass('hide');
			$('#residential .show-tp').addClass('hide');
		}
	};

	ResidentialListings.setPositions = function() {
	  // loop through and give each task a data-pos
	  // attribute that holds its position in the DOM
	  $('#residential .img-thumbnail').each(function(i) {
	      $(this).attr("data-pos", i+1);
	  });
	};

	ResidentialListings.makeSortable = function() {
		// call sortable on our div with the sortable class
	  $('#residential .sortable').sortable({
			forcePlaceholderSize: true,
			placeholderClass: 'col col-xs-2 border border-maroon',
			dragImage: null
	  });
	};

	ResidentialListings.updateRemoveImgLinks = function() {
		$('#residential .delete-unit-img').click(function(event) {
			event.preventDefault();
			var id = $(this).attr('data-id'); 
			var unit_id = $(this).attr('data-unit-id');
			console.log(id, unit_id);
			ResidentialListings.removeImage(id, unit_id);
		});
	};
	
	ResidentialListings.initialize = function() {

		$('#residential .has-fee').click(ResidentialListings.toggleFeeOptions);
		ResidentialListings.toggleFeeOptions();

		// index filtering
		$('#residential input').keydown(ResidentialListings.preventEnter);
	  $('#residential #address').change(ResidentialListings.throttledSearch);
	  $('#residential #unit').change(ResidentialListings.throttledSearch);
	  $('#residential #rent_min').change(ResidentialListings.throttledSearch);
	  $('#residential #rent_max').change(ResidentialListings.throttledSearch);
	  $('#residential #bed_min').change(ResidentialListings.throttledSearch);
	  $('#residential #bed_max').change(ResidentialListings.throttledSearch);
	  $('#residential #bath_min').change(ResidentialListings.throttledSearch);
	  $('#residential #bath_max').change(ResidentialListings.throttledSearch);
	  $('#residential #landlord').change(ResidentialListings.throttledSearch);
	  $('#residential #available_starting').blur(ResidentialListings.throttledSearch);
	  $('#residential #available_before').blur(ResidentialListings.throttledSearch);
	  $('#residential #pet_policy_shorthand').change(ResidentialListings.throttledSearch);
	  $('#residential #status').change(ResidentialListings.throttledSearch);
	  $('#residential #features').change(ResidentialListings.throttledSearch);
	  $('#residential #has_fee').change(ResidentialListings.throttledSearch);
	  $('#residential #neighborhood_ids').change(ResidentialListings.throttledSearch);
	  $('#residential #unit_feature_ids').change(ResidentialListings.throttledSearch);
	  $('#residential #building_feature_ids').change(ResidentialListings.throttledSearch);
	  // remove individual features by clicking on 'x' button
	  $('#residential .remove-unit-feature').click(ResidentialListings.removeUnitFeature);
	  $('#residential .remove-building-feature').click(ResidentialListings.removeBuildingFeature);
	  $('#residential .remove-neighborhood').click(ResidentialListings.removeNeighborhood);

	  // print pdf from the index page
	  $('#residential .btn-print-list').click( function(event) {
		  // show spinner
		  $(this).toggleClass('active');
		});

		var available_by = $('#residential .datepicker').attr('data-available-by');
		if (available_by) {
			$('#residential .datepicker').data("DateTimePicker").date(available_by);
		}

		ResidentialListings.updateOverviewMap();

		// google map on show page
		var bldg_address = $('#map_canvas').attr('data-address') ? $('#map_canvas').attr('data-address') : 'New York, NY, USA';
		$("#runit-panel").geocomplete({
	  	map: "#map_canvas",
	  	location: bldg_address,
	  	details: ".details"
	  }).bind("geocode:result", function(event, result){
	    //console.log(result);
	  }).bind("geocode:error", function(event, result){
	    //console.log("[ERROR]: " + result);
	  });

	  // for drag n dropping photos

		// disable auto discover
		Dropzone.autoDiscover = false;
	 
		// grap our upload form by its id
		$("#runit-dropzone").dropzone({
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
				$(file.previewTemplate).find('.dz-remove').attr('unit_id', response.unitID);
				// add the dz-success class (the green tick sign)
				$(file.previewElement).addClass("dz-success");
				console.log('/residential_listings/' + response.unitID + '/refresh_images');
				$.getScript('/residential_listings/' + response.unitID + '/refresh_images')
				file.previewElement.remove();
			},
			//when the remove button is clicked
			removedfile: function(file){
				// grap the id of the uploaded file we set earlier
				var id = $(file.previewTemplate).find('.dz-remove').attr('id'); 
				var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
				ResidentialListings.removeImage(id, unit_id);
				file.previewElement.remove();
			}
		});

		ResidentialListings.updateRemoveImgLinks();

		$('.carousel-indicators > li:first-child').addClass('active');
		$('.carousel-inner > .item:first-child').addClass('active');

    ResidentialListings.setPositions();
    ResidentialListings.makeSortable();
	  // after the order changes
    $('#residential .sortable').sortable().bind('sortupdate', function(e, ui) {
        // array to store new order
        updated_order = []
        // set the updated positions
        ResidentialListings.setPositions();
 				
        // populate the updated_order array with the new task positions
        $('.img-thumbnail').each(function(i){
          updated_order.push({ id: $(this).data('id'), position: i+1 });
        });
 				console.log(updated_order);
        // send the updated order via ajax
        var runit_id = $('#residential').attr('data-runit-id');
        $.ajax({
          type: "PUT",
          url: '/residential_listings/' + runit_id + '/unit_images/sort',
          data: { order: updated_order }
        });
    });

	};

})();

$(document).ready(ResidentialListings.initialize);
