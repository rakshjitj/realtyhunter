ResidentialUnits = {};

// TODO: break this up by controller action

(function() {
	// for searching on the index page
	ResidentialUnits.doSearch = function (event) {
		//console.log('PERFORMING SEARCH');
		// sanitize invalid input before submitting
	  if ($('#neighborhood_ids').val() == "{:id=>\"neighborhood_ids\"}") {
	    $('#neighborhood_ids').val('');
	  }
	  if ($('#building_feature_ids').val() == "{:id=>\"building_feature_ids\"}") {
	    $('#building_feature_ids').val('');
	  }
	  if ($('#unit_feature_ids').val() == "{:id=>\"unit_feature_ids\"}") {
	    $('#unit_feature_ids').val('');
	  }

	  var search_path = $('#res-search-filters').attr('data-search-path');
	  $.ajax({
	    url: search_path,
	    data: {
        address: $('#address').val(),
        unit: $('#unit').val(),
        rent_min: $('#rent_min').val(),
        rent_max: $('#rent_max').val(),
        bed_min: $('#bed_min').val(),
        bed_max: $('#bed_max').val(),
        bath_min: $('#bath_min').val(),
        bath_max: $('#bath_max').val(),
        landlord: $('#landlord').val(),
        pet_policy_shorthand: $('#pet_policy_shorthand').val(),
        status: $('#status').val(),
        features: $('#features').val(),
        has_fee: $('#has_fee').val(),
        neighborhood_ids: $('#neighborhood_ids').val(),
        unit_feature_ids: $('#unit_feature_ids').val(),
        building_feature_ids: $('#building_feature_ids').val(),
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

	ResidentialUnits.removeUnitFeature = function (event) {
  	event.preventDefault();
	  var feature_id = $(this).attr('data-id');
  	var idx = $('#unit_feature_ids').val().indexOf(feature_id);
  	//console.log(feature_id, idx, feature_id.length, $('#unit_feature_ids').val());
  	$('#unit_feature_ids').val( $('#unit_feature_ids').val().replace(feature_id, '') );
  	//console.log('new val is', $('#unit_feature_ids').val() );
  	$(this).remove();
  	ResidentialUnits.throttledSearch();
  };

  ResidentialUnits.removeBuildingFeature = function (event) {
  	event.preventDefault();
	  var feature_id = $(this).attr('data-id');
  	var idx = $('#building_feature_ids').val().indexOf(feature_id);
  	$('#building_feature_ids').val( $('#building_feature_ids').val().replace(feature_id, '') );
  	$(this).remove();
  	ResidentialUnits.throttledSearch();
  };

  ResidentialUnits.removeNeighborhood = function (event) {
  	event.preventDefault();
	  var feature_id = $(this).attr('data-id');
  	var idx = $('#neighborhood_ids').val().indexOf(feature_id);
  	$('#neighborhood_ids').val( $('#neighborhood_ids').val().replace(feature_id, '') );
  	$(this).remove();
  	ResidentialUnits.throttledSearch();
  };

	// search as user types
	ResidentialUnits.timer;

	ResidentialUnits.throttledSearch = function () {
		console.log('throttling?');
		//clear any interval on key up
		if (ResidentialUnits.timer) {
			console.log('yes, clearing');
		  clearTimeout(ResidentialUnits.timer);
		}
		// if (jqXHR && jqXHR.abort) { 
		// 	jqXHR.abort(); 
		// }
	  ResidentialUnits.timer = setTimeout(ResidentialUnits.doSearch, 500);
	};

	// change enter key to tab
	ResidentialUnits.preventEnter = function (event) {
	  if (event.keyCode == 13) {
	    //$('#checkbox_active').focus();
	    return false;
	  }
	};

	ResidentialUnits.removeImage = function (id, unit_id) {
		// make a DELETE ajax request to delete the file
		$.ajax({
			type: 'DELETE',
			url: '/residential_units/' + unit_id + '/unit_images/' + id,
			success: function(data){
				//console.log(data.message);
				$.getScript('/residential_units/' + unit_id + '/refresh_images')
			},
			error: function(data) {
				//console.log('ERROR:', data);
			}
		});
	};

	// for giant google map
	ResidentialUnits.buildContentString = function (key, info) {
	  var contentString = '<strong>' + key + '</strong><hr />';
	  for (var i=0; i<info['units'].length; i++) {
	    contentString += '<a href="/residential_units/' + info['units'][i].id + '">#' + info['units'][i].building_unit + '</a>: ' + info['units'][i].beds + ' beds / ' 
	      + info['units'][i].baths + ' baths $' + info['units'][i].rent + '<br />';
	    if (i == 5) {
	      contentString += '<a href="/residential_units?building_id=' + info['building_id'] + '">View more...</a>';
	      break;
	    }
	  }
	  return contentString;
	};

	ResidentialUnits.updateOverviewMap = function (in_data) {
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
		    	var content = ResidentialUnits.buildContentString(key, info);
		    	infoWindow = new google.maps.InfoWindow({
			    	content: content
			    });
		      infoWindow.open(map, marker);
		    });
			});
		}
	};

	ResidentialUnits.toggleFeeOptions = function(event) {
		var isChecked = $('.has-fee').prop('checked');
		if (isChecked) {
			$('.show-op').addClass('hide');
			$('.show-tp').removeClass('hide');
		} else {
			$('.show-op').removeClass('hide');
			$('.show-tp').addClass('hide');
		}
	};

	ResidentialUnits.initialize = function() {

		$('.has-fee').click(ResidentialUnits.toggleFeeOptions);
		ResidentialUnits.toggleFeeOptions();

		// index filtering
		$('input').keydown(ResidentialUnits.preventEnter);
	  $('#address').keyup(ResidentialUnits.throttledSearch);
	  $('#unit').keyup(ResidentialUnits.throttledSearch);
	  $('#rent_min').keyup(ResidentialUnits.throttledSearch);
	  $('#rent_max').keyup(ResidentialUnits.throttledSearch);
	  $('#bed_min').keyup(ResidentialUnits.throttledSearch);
	  $('#bed_max').keyup(ResidentialUnits.throttledSearch);
	  $('#bath_min').keyup(ResidentialUnits.throttledSearch);
	  $('#bath_max').keyup(ResidentialUnits.throttledSearch);
	  $('#landlord').keyup(ResidentialUnits.throttledSearch);
	  $('#pet_policy_shorthand').change(ResidentialUnits.throttledSearch);
	  $('#status').change(ResidentialUnits.throttledSearch);
	  $('#features').change(ResidentialUnits.throttledSearch);
	  $('#has_fee').change(ResidentialUnits.throttledSearch);
	  $('#neighborhood_ids').change(ResidentialUnits.throttledSearch);
	  $('#unit_feature_ids').change(ResidentialUnits.throttledSearch);
	  $('#building_feature_ids').change(ResidentialUnits.throttledSearch);
	  // remove individual features by clicking on 'x' button
	  $('.remove-unit-feature').click(ResidentialUnits.removeUnitFeature);
	  $('.remove-building-feature').click(ResidentialUnits.removeBuildingFeature);
	  $('.remove-neighborhood').click(ResidentialUnits.removeNeighborhood);

	  // print pdf from the index page
	  $('.btn-print-list').click( function(event) {
		  // show spinner
		  $(this).toggleClass('active');
		});

		ResidentialUnits.updateOverviewMap();

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
		$("#unit-dropzone").dropzone({
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
				$.getScript('/residential_units/' + response.unitID + '/refresh_images')
				file.previewElement.remove();
			},
			//when the remove button is clicked
			removedfile: function(file){
				// grap the id of the uploaded file we set earlier
				var id = $(file.previewTemplate).find('.dz-remove').attr('id'); 
				var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
				ResidentialUnits.removeImage(id, unit_id);
				file.previewElement.remove();
			}
		});

		$('.delete-unit-img').click(function(event) {
			event.preventDefault();
			var id = $(this).attr('data-id'); 
			var unit_id = $(this).attr('data-unit-id');
			//console.log(id, unit_id);
			ResidentialUnits.removeImage(id, unit_id);
			// TODO: WTF why is this breaking?
		});

		$('.carousel-indicators > li:first-child').addClass('active');
		$('.carousel-inner > .item:first-child').addClass('active')
	};

})();

$(document).ready(ResidentialUnits.initialize);


