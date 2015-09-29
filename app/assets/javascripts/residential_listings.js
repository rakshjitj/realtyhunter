ResidentialListings = {};

// TODO: break this up by controller action

(function() {

	ResidentialListings.selectedListings = [];

	// private
	ResidentialListings.checkTheBox = function(item) {
		item.addClass('fa-check-square').removeClass('fa-square-o');
	};
	// private
	ResidentialListings.uncheckTheBox = function(item) {
		item.addClass('fa-square-o').removeClass('fa-check-square');
	};
	// private
	ResidentialListings.updateSelectedButton = function() {
		$('#selected-listings-dropdown').html(ResidentialListings.selectedListings.length + " Selected Listings <span class=\"caret\"></span>");
		if (ResidentialListings.selectedListings.length == 0) {
			$('#selected-listings-dropdown').addClass("disabled");
		} else {
			$('#selected-listings-dropdown').removeClass("disabled");
		}

		// update the hidden tag with the latest list of ids
		$('#residential_listing_listing_ids').val(ResidentialListings.selectedListings);
	};
	// private
	// if any individual listings get unchecked, then uncheck
	// the main toggle inside our th
	ResidentialListings.uncheckHeadToggle = function() {
		ResidentialListings.uncheckTheBox($('th > i'));
	};

	ResidentialListings.selectAllListings = function() {
		var isChecked = $(this).hasClass('fa-check-square');
		if (isChecked) {
			// uncheck all boxes, clear our list
			ResidentialListings.uncheckTheBox($(this));
			ResidentialListings.selectedListings = [];

			$('td > i').map(function() {
				if ($(this).hasClass('fa-check-square')) {
					ResidentialListings.uncheckTheBox($(this));
				}
			});
		} else {
			// check all boxes, fill our list
			ResidentialListings.checkTheBox($(this));
			ResidentialListings.selectedListings = $('tr').map(function() {
				return $(this).attr('data-id');
			}).get();

			$('td > i').map(function() {
				if ($(this).hasClass('fa-square-o')) {
					ResidentialListings.checkTheBox($(this));
				}
			});
		}

		ResidentialListings.updateSelectedButton();
	};

	ResidentialListings.toggleListingSelection = function() {
		// TODO: cap the max # of listings you can select?
		var isChecked = $(this).hasClass('fa-check-square');
		var listing_id = $(this).parent().parent().attr('data-id');
		
		if (isChecked) {
			//$(this).addClass('fa-square-o').removeClass('fa-check-square');
			ResidentialListings.uncheckTheBox($(this));
			ResidentialListings.selectedListings.splice(ResidentialListings.selectedListings.indexOf(listing_id), 1);
			ResidentialListings.uncheckHeadToggle();
		} else {
			//$(this).addClass('fa-check-square').removeClass('fa-square-o');
			ResidentialListings.checkTheBox($(this));
			ResidentialListings.selectedListings.push(listing_id);
		}

		ResidentialListings.updateSelectedButton();
	};

	ResidentialListings.indexMenuActions = {
		
		'send': function() {
			console.log('sending!');
			var params = 'residential_listing_ids=' + ResidentialListings.selectedListings.join(",");
			window.location.href = '/residential_listings/print_list?' + params;
		},
		'listingsSheet': function() {
			//console.log('sheet!');
			var params = 'residential_listing_ids=' + ResidentialListings.selectedListings.join(",");
			window.location.href = '/residential_listings/print_public?' + params;
		},
		'internalListingsSheet': function() {
			var params = 'residential_listing_ids=' + ResidentialListings.selectedListings.join(",");
			window.location.href = '/residential_listings/print_private?' + params;
		}
	};

	ResidentialListings.showSpinner = function() {
		$('.res-spinner-desktop').show();
	};

	ResidentialListings.hideSpinner = function() {
		$('.res-spinner-desktop').hide();
	};

	// for searching on the index page
	ResidentialListings.doSearch = function (sort_by_col, sort_direction) {
		//console.log(sort_by_col, sort_direction);
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
	  
	  ResidentialListings.showSpinner();

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
        sort_by: sort_by_col,
        direction: sort_direction,
	    },
	    dataType: 'script',
	    success: function(data) {
	    	//console.log('SUCCESS:', data.responseText);
	    	ResidentialListings.hideSpinner();
			},
			error: function(data) {
				//console.log('ERROR:', data.responseText);
				ResidentialListings.hideSpinner();
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
		//console.log('throttling?');
		//clear any interval on key up
		if (ResidentialListings.timer) {
			//console.log('yes, clearing');
		  clearTimeout(ResidentialListings.timer);
		}
	  ResidentialListings.timer = setTimeout(ResidentialListings.doSearch, 500);
	};

	// change enter key to tab
	ResidentialListings.preventEnter = function (event) {
	  if (event.keyCode == 13) {
	    //$('#checkbox_active').focus();
	    return false;
	  }
	};

	ResidentialListings.removeImage = function (id, runit_id) {
		// make a DELETE ajax request to delete the file
		$.ajax({
			type: 'DELETE',
			url: '/residential_listings/' + runit_id + '/unit_images/' + id,
			success: function(data){
				//console.log(data.message);
				$.getScript('/residential_listings/' + runit_id + '/refresh_images')
			},
			error: function(data) {
				//console.log('ERROR:', data);
			}
		});
	};

	// for giant google map
	ResidentialListings.buildContentString = function (key, info) {
	  var contentString = '<strong>' + key + '</strong><br />'; //<hr />';
	  for (var i=0; i<info['units'].length; i++) {
	    contentString += '<a href="https://myspace-realty-monster.herokuapp.com/residential_listings/' + info['units'][i].id + '">#' + info['units'][i].building_unit + '</a> ' + info['units'][i].beds + ' bd / ' 
	      + info['units'][i].baths + ' baths $' + info['units'][i].rent + '<br />';
	    if (i == 5) {
	      contentString += '<a href="https://myspace-realty-monster.herokuapp.com/residential_listings?building_id=' + info['building_id'] + '">View more...</a>';
	      break;
	    }
	  }
	  return contentString;
	};

	ResidentialListings.map;
	ResidentialListings.overlays;

	ResidentialListings.updateOverviewMap = function(in_data) {
		ResidentialListings.overlays.clearLayers();
    var markers = new L.MarkerClusterGroup({
    	maxClusterRadius: 30 // lean towards showing more individual markers
    }).addTo(ResidentialListings.overlays);//{ showCoverageOnHover: false });
		
    var dataPoints;
	  // if updating from an ajax call, in_data will hava content.
	  // we load data from a data attribute on page load, but that remains cached forever -
	  // it will not update with subsequent ajax calls.
	  if (in_data) {
	  	dataPoints = JSON.parse(in_data);
	  } else {
	  	dataPoints = JSON.parse($('#big-map').attr('data-map-points'));
	  }
	  var features = [];
	  Object.keys(dataPoints).forEach(function(key, index) {
	    // draw each marker + load with data
	    var info = dataPoints[key];
	    var content = ResidentialListings.buildContentString(key, info);
	    var marker = L.marker(new L.LatLng(info.lat, info.lng), {
	      icon: L.mapbox.marker.icon({
	      	'marker-size': 'small', 
	      	'marker-color': '#f86767'
	      }),
	      'title': key,
	    });
	    marker.bindPopup(content);
      markers.addLayer(marker);
	    // var feature = {
     //    type: 'Feature',
     //    properties: {
     //        title: key,
     //        'marker-color': '#f86767',
     //        'description': ResidentialListings.buildContentString(key, info),
     //        'marker-size': 'small'
     //    },
     //    geometry: {
     //        type: 'Point',
     //        coordinates: [info.lng, info.lat]
     //    }
    	// };
    	
    	// features.push(feature);
		});

		var geojson = {
			'type': 'FeatureCollection',
			'features': features
		};

    //markerLayer.setGeoJSON(geojson);
    var geoJsonLayer = L.geoJson(geojson);
    //geoJsonLayer.clearLayers();
    markers.addLayer(geoJsonLayer);
 		ResidentialListings.map.addLayer(markers);
    ResidentialListings.map.fitBounds(markers.getBounds());
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

	ResidentialListings.inheritFeeOptions = function() {
		bldg_id = $('#residential #residential_listing_unit_building_id').val();
		console.log('got new ids', bldg_id);
		
		$.ajax({
			type: 'GET',
			url: '/residential_listings/fee_options/',
			data: {
				building_id: bldg_id,
			},
			//success: function(data) {},
			//error: function(data) {}
		});
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
			var runit_id = $(this).attr('data-runit-id');
			//console.log(id, runit_id);
			ResidentialListings.removeImage(id, runit_id);
		});
	};
	
	ResidentialListings.setupSortableColumns = function() {
		$('#residential .th-sortable').click(function(e) {
			e.preventDefault();
			
			if ($(this).hasClass('selected-sort')) {
				// switch sort order
				var i = $('.selected-sort i');
				if (i) {
					if (i.hasClass('glyphicon glyphicon-triangle-bottom')) {
						i.removeClass('glyphicon glyphicon-triangle-bottom').addClass('glyphicon glyphicon-triangle-top');
						$(this).attr('data-direction', 'desc');
					}
					else if (i.hasClass('glyphicon glyphicon-triangle-top')) {
						i.removeClass('glyphicon glyphicon-triangle-top').addClass('glyphicon glyphicon-triangle-bottom');
						$(this).attr('data-direction', 'asc');
					}
				}
			} else {
				// remove selection from old row
				$('.selected-sort').attr('data-direction', '');
				$('th i').remove(); // remove arrows
				$('.selected-sort').removeClass('selected-sort');
				// select new column
				$(this).addClass('selected-sort').append(' <i class="glyphicon glyphicon-triangle-bottom"></i>');
				$(this).attr('data-direction', 'asc');
			}

			var sort_by_col = $(this).attr('data-sort');
			var sort_direction = $(this).attr('data-direction');
			ResidentialListings.doSearch(sort_by_col, sort_direction);
		});
	};

	ResidentialListings.initialize = function() {
		document.addEventListener("page:restore", function() {
		  ResidentialListings.hideSpinner();
		});
		ResidentialListings.hideSpinner();
		$('#residential a').click(function() {
			ResidentialListings.showSpinner();
		});

		// main index table
		ResidentialListings.setupSortableColumns();		

		$('.close').click(function() {
			//console.log('detected click');
			ResidentialListings.hideSpinner();
		});

		$('#residential .has-fee').click(ResidentialListings.toggleFeeOptions);
		// when editing form
		ResidentialListings.toggleFeeOptions();
		// when creating a new listing, inherit TP/OP from building's landlord
		$('#residential #residential_listing_unit_building_id').change(ResidentialListings.inheritFeeOptions);

		// index filtering
		$('#residential input').keydown(ResidentialListings.preventEnter);
		$('#residential #address').bind('railsAutocomplete.select', ResidentialListings.throttledSearch);
	  $('#residential #address').change(ResidentialListings.throttledSearch);
	  $('#residential #unit').change(ResidentialListings.throttledSearch);
	  $('#residential #rent_min').change(ResidentialListings.throttledSearch);
	  $('#residential #rent_max').change(ResidentialListings.throttledSearch);
	  $('#residential #bed_min').change(ResidentialListings.throttledSearch);
	  $('#residential #bed_max').change(ResidentialListings.throttledSearch);
	  $('#residential #bath_min').change(ResidentialListings.throttledSearch);
	  $('#residential #bath_max').change(ResidentialListings.throttledSearch);
	  $('#residential #landlord').bind('railsAutocomplete.select', ResidentialListings.throttledSearch);
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
	 //  $('#residential .btn-print-list').click( function(event) {
		//   ResidentialListings.showSpinner();
		//   $(this).toggleClass('active');
		// });

		// index page - selecting listings menu dropdown
		$('#emailListings').click(function(e) {
			$('#residential_listing_recipients').val('');
			//$('#residential_listing_title').val('');
			$('#residential_listing_message').val('');
			e.preventDefault();
		});
		$('tbody').on('click', 'i', ResidentialListings.toggleListingSelection);
		$('.select-all-listings').click(ResidentialListings.selectAllListings);
		ResidentialListings.selectedListings = [];
		$('.selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in ResidentialListings.indexMenuActions) ResidentialListings.indexMenuActions[action]();
		});

		// make sure datepicker is formatted before setting initial date below
		$('.datepicker').datetimepicker({
		  viewMode: 'days',
		  format: 'MM/DD/YYYY',
		  allowInputToggle: true
		});
		var available_by = $('#residential .datepicker').attr('data-available-by');
		if (available_by) {
			$('#residential .datepicker').data("DateTimePicker").date(available_by);
		}

		if ($('#big-map').length > 0) {
			// mapbox
			L.mapbox.accessToken = $('#mapbox-token').attr('data-mapbox-token');
	    ResidentialListings.map = L.mapbox.map('big-map', 'rakelblujeans.8594241c', { zoomControl: false })
	    	.setView([40.6739591, -73.9570342], 13);

			new L.Control.Zoom({ position: 'topright' }).addTo(ResidentialListings.map);
	    //map.removeLayer(marker)
	    //var markerLayer = L.mapbox.featureLayer().addTo(map);
	    ResidentialListings.overlays = L.layerGroup().addTo(ResidentialListings.map);
	    ResidentialListings.updateOverviewMap();
		}

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
				//console.log(response);
				$(file.previewTemplate).find('.dz-remove').attr('id', response.fileID);
				$(file.previewTemplate).find('.dz-remove').attr('runit_id', response.runitID);
				// add the dz-success class (the green tick sign)
				$(file.previewElement).addClass("dz-success");
				//console.log('/residential_listings/' + response.runitID + '/refresh_images');
				$.getScript('/residential_listings/' + response.runitID + '/refresh_images')
				file.previewElement.remove();
			},
			//when the remove button is clicked
			removedfile: function(file){
				// grap the id of the uploaded file we set earlier
				var id = $(file.previewTemplate).find('.dz-remove').attr('id'); 
				var unit_id = $(file.previewTemplate).find('.dz-remove').attr('runit_id');
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
          updated_order.push({ id: $(this).data('id'), position: i });
        });
 				//console.log(updated_order);
        // send the updated order via ajax
        var runit_id = $('#residential').attr('data-runit-id');
        $.ajax({
          type: "PUT",
          url: '/residential_listings/' + runit_id + '/unit_images/sort',
          data: { order: updated_order }
        });
    });

    // activate tooltips
    $('[data-toggle="tooltip"]').tooltip();

	};

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
  	ResidentialListings.hideSpinner();
  }
});


$(document).ready(ResidentialListings.initialize);
