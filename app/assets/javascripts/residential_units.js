var timer2;
function clearSpinner() {
  // remove the spinner after download completes.
  // this is a very hackish way of roughly estimating how long
  // the download takes to complete
  clearInterval(timer2);
  $('.btn-print-list').toggleClass('active');
};

$('.btn-print-list').click( function(event) {
  // show spinner
  $(this).toggleClass('active');
  timer2 = setTimeout(clearSpinner, 15000);
});

function doSearch(event) {
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
      search_params: {
        address: $('#address').val(),
        unit: $('#unit').val(),
        rent_min: $('#rent_min').val(),
        rent_max: $('#rent_max').val(),
        bed_min: $('#bed_min').val(),
        bed_max: $('#bed_max').val(),
        bath_min: $('#bath_min').val(),
        bath_max: $('#bath_max').val(),
        landlord: $('#landlord').val(),
        pet_policy_id: $('#pet_policy_id').val(),
        status: $('#status').val(),
        features: $('#features').val(),
        neighborhood_ids: $('#neighborhood_ids').val(),
        unit_feature_ids: $('#unit_feature_ids').val(),
        building_feature_ids: $('#building_feature_ids').val(),
      } 
    },
    dataType: "script"
  });
};

// search as user types
var timer;
function throttledSearch() {
  clearInterval(timer);  //clear any interval on key up
  timer = setTimeout(doSearch, 500);
};

// change enter key to tab
function preventEnter(event) {
  if (event.keyCode == 13) {
    //$('#checkbox_active').focus();
    return false;
  }
};

function removeImage(id, unit_id) {
	// make a DELETE ajax request to delete the file
	$.ajax({
		type: 'DELETE',
		url: '/residential_units/' + unit_id + '/unit_images/' + id,
		success: function(data){
			console.log(data.message);
			$.getScript('/residential_units/' + unit_id + '/refresh_images')
		},
		error: function(data) {
			console.log('ERROR:', data);
		}
	});
};

function buildContentString(key, info) {
	console.log(key, info);
  var contentString = '<strong>' + key + '</strong><hr />';
  for (var i=0; i<info['units'].length; i++) {
    contentString += '#<a href="/residential_units/' + info['units'][i].id + '">' + info['units'][i].building_unit + '</a>: ' + info['units'][i].beds + ' beds / ' 
      + info['units'][i].baths + ' baths $' + info['units'][i].rent + '<br />';
    if (i == 5) {
      contentString += '<a href="/residential_units?building_id=' + info['building_id'] + '">View more...</a>';
      break;
    }
  }
  return contentString;
};


$(document).ready(function(){
	// google map
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

	// index filtering
	$('input').keydown(preventEnter);
  $('#address').keyup(throttledSearch);
  $('#unit').keyup(throttledSearch);
  $('#rent_min').keyup(throttledSearch);
  $('#rent_max').keyup(throttledSearch);
  $('#bed_min').keyup(throttledSearch);
  $('#bed_max').keyup(throttledSearch);
  $('#bath_min').keyup(throttledSearch);
  $('#bath_max').keyup(throttledSearch);
  $('#landlord').keyup(throttledSearch);
  $('#pet_policy_id').change(throttledSearch);
  $('#status').change(throttledSearch);
  $('#features').change(throttledSearch);
  $('#neighborhood_ids').change(throttledSearch);
  $('#unit_feature_ids').change(throttledSearch);
  $('#building_feature_ids').change(throttledSearch);

	// for displaying the map points on the index page
	if ($('#big-map').length > 0) {
		var mapOptions = {
	    center: { lat: 40.6739591, lng: -73.9570342},
	    zoom: 12
	  };
	  var map = new google.maps.Map(document.getElementById('big-map'), mapOptions);

	  var dataPoints = JSON.parse($('#big-map').attr('data-map-points'));
	  //console.log(dataPoints);
	  var markers = [];
	  var contentStrings = [];

	  Object.keys(dataPoints).forEach(function(key, index) {
	    // draw marker
	    info = dataPoints[key];
	    var myLatlng = new google.maps.LatLng(info.lat, info.lng);
	    var marker = new google.maps.Marker({
	      map:map,
	      animation: google.maps.Animation.DROP,
	      position: myLatlng,
	      //title: 'Hello World!'
	    });

	    // populate infoWindow
	    var contentStr= buildContentString(key, info);
	    var infowindow = new google.maps.InfoWindow({
	     content: contentStr
	    });
	    //console.log(myLatlng, contentStr);
	    google.maps.event.addListener(marker, 'click', function() {
	      infowindow.open(map, marker);
	    });
		});
	}

  // neighborhoods modal
  $('#myTab a:first').tab('show')

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
			removeImage(id, unit_id);
			file.previewElement.remove();
		}
	});

	$('.delete-unit-img').click(function(event) {
		event.preventDefault();
		var id = $(this).attr('data-id'); 
		var unit_id = $(this).attr('data-unit-id');
		console.log(id, unit_id);
		removeImage(id, unit_id);
		// TODO: WTF why is this breaking?
	});

	$('.carousel-indicators > li:first-child').addClass('active');
	$('.carousel-inner > .item:first-child').addClass('active')
	
});// end document ready