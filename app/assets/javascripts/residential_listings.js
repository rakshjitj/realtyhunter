ResidentialListings = {};

// TODO: break this up by controller action

(function() {
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

	  Listings.showSpinner();

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
        roomsharing_filter: $('#residential #roomsharing_filter').prop('checked'),
        unassigned_filter: $('#residential #unassigned_filter').prop('checked'),
        primary_agent_id:  $('#residential #primary_agent_id').val(),
        sort_by: sort_by_col,
        direction: sort_direction,
	    },
	    dataType: 'script',
	    success: function(data) {
	    	//console.log('SUCCESS:', data.responseText);
	    	Listings.hideSpinner();
			},
			error: function(data) {
				//console.log('ERROR:', data.responseText);
				Listings.hideSpinner();
			}
	  });

		ResidentialListings.passiveRealTimeUpdate();
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

	ResidentialListings.timer;
	ResidentialListings.announcementsTimer;

	ResidentialListings.clearAnnouncementsTimer = function() {
		if (ResidentialListings.announcementsTimer) {
		  clearTimeout(ResidentialListings.announcementsTimer);
		}
	};

	ResidentialListings.clearTimer = function() {
		if (ResidentialListings.timer) {
		  clearTimeout(ResidentialListings.timer);
		}
	};

	// update the announcements every 60 seconds
	ResidentialListings.updateAnnouncements = function() {
		//console.log('updateAnnouncements ', $('#residential').length);
		if ($('#residential').length) {
			//console.log('updating ann');
			$.ajax({
	      url: '/residential_listings/update_announcements',
	    });

			ResidentialListings.announcementsTimer = setTimeout(ResidentialListings.updateAnnouncements, 60 * 1 * 1000);
		}
	};

	// if a user remains on this page for an extended amount of time,
	// refresh the page every so often. We want to make sure they are
	// always viewing the latest data.
	ResidentialListings.passiveRealTimeUpdate = function() {
		if ($('#residential').length) {
			ResidentialListings.clearTimer();
			// update every few minutes
		  ResidentialListings.timer = setTimeout(ResidentialListings.doSearch, 60 * 3 * 1000);
		}
	};

	// search as user types
	ResidentialListings.throttledSearch = function () {
		//clear any interval on key up
		ResidentialListings.clearTimer();
		ResidentialListings.timer = setTimeout(ResidentialListings.doSearch, 500);
	};

	// change enter key to tab
	ResidentialListings.preventEnter = function (event) {
	  if (event.keyCode == 13) {
	    return false;
	  }
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
	  	dataPoints = JSON.parse($('#r-big-map').attr('data-map-points'));
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
		//console.log('got new ids', bldg_id);

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

	// any phone #'s listed in 'access info' on main index pg should
  // be automatically detected
	ResidentialListings.detectPhoneNumbers = function () {
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {

			var countrycodes = "1"
			var delimiters = "-|\\.|—|–|&nbsp;"
			var phonedef = "\\+?(?:(?:(?:" + countrycodes + ")(?:\\s|" + delimiters + ")?)?\\(?[2-9]\\d{2}\\)?(?:\\s|" + delimiters + ")?[2-9]\\d{2}(?:" + delimiters + ")?[0-9a-z]{4})"
			var spechars = new RegExp("([- \(\)\.:]|\\s|" + delimiters + ")","gi") //Special characters to be removed from the link
			var phonereg = new RegExp("((^|[^0-9])(href=[\"']tel:)?((?:" + phonedef + ")[\"'][^>]*?>)?(" + phonedef + ")($|[^0-9]))","gi")

			function ReplacePhoneNumbers(oldhtml) {
				//Created by Jon Meck at LunaMetrics.com - Version 1.0
				var newhtml = oldhtml.replace(/href=['"]callto:/gi,'href="tel:')
				newhtml = newhtml.replace(phonereg, function ($0, $1, $2, $3, $4, $5, $6) {
				    if ($3) return $1;
				    else if ($4) return $2+$4+$5+$6;
				    else return $2+"<a href='tel:"+$5.replace(spechars,"")+"'>"+$5+"</a>"+$6; });
				return newhtml;
			}

			$('.access-info').map(function() {
				$(this).html(ReplacePhoneNumbers($(this).html()))
			});
		}
	};

	ResidentialListings.initializeImageDropzone = function() {
    // grap our upload form by its id
    $("#runit-dropzone").dropzone({
      // restrict image size to a maximum 1MB
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
        $.getScript('/residential_listings/' + response.runitID + '/refresh_images')
        file.previewElement.remove();
      },
      //when the remove button is clicked
      removedfile: function(file){
        // grap the id of the uploaded file we set earlier
        var id = $(file.previewTemplate).find('.dz-remove').attr('id');
        var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
        DropZoneHelper.removeImage(id, unit_id, 'residential_listings');
        file.previewElement.remove();
      }
    });

    DropZoneHelper.updateRemoveImgLinks('residential', 'residential_listings');
    DropZoneHelper.updateRotateImgLinks('residential', 'residential_listings');

    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active');

    DropZoneHelper.setPositions('residential', 'images');
    DropZoneHelper.makeSortable('residential', 'images');

    // after the order changes
    $('#residential .sortable').sortable().bind('sortupdate', function(e, ui) {
        // array to store new order
        updated_order = []
        // set the updated positions
        DropZoneHelper.setPositions('residential', 'images');

        // populate the updated_order array with the new task positions
        $('.img').each(function(i) {
          updated_order.push({ id: $(this).data('id'), position: i});
        });
        //console.log(updated_order);
        // send the updated order via ajax
        var unit_id = $('#residential').attr('data-unit-id');
        $.ajax({
          type: "PUT",
          url: '/residential_listings/' + unit_id + '/unit_images/sort',
          data: { order: updated_order }
        });
    });
  };

  ResidentialListings.initializeDocumentsDropzone = function() {
    // grap our upload form by its id
    $("#runit-dropzone-docs").dropzone({
      // show remove links on each image upload
      addRemoveLinks: true,
      // if the upload was successful
      success: function(file, response){
        // find the remove button link of the uploaded file and give it an id
        // based of the fileID response from the server
        $(file.previewTemplate).find('.dz-remove').attr('id', response.fileID);
        $(file.previewTemplate).find('.dz-remove').attr('unit_id', response.runitID);
        // add the dz-success class (the green tick sign)
        $(file.previewElement).addClass("dz-success");
        $.getScript('/residential_listings/' + response.runitID + '/refresh_documents')
        file.previewElement.remove();
      },
      //when the remove button is clicked
      removedfile: function(file){
        // grap the id of the uploaded file we set earlier
        var id = $(file.previewTemplate).find('.dz-remove').attr('id');
        var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
        DropZoneHelper.removeDocument(id, unit_id, 'residential_listings');
        file.previewElement.remove();
      }
    });

    DropZoneHelper.updateRemoveDocLinks('residential', 'residential_listings');

    // $('.carousel-indicators > li:first-child').addClass('active');
    // $('.carousel-inner > .item:first-child').addClass('active');

    DropZoneHelper.setPositions('residential', 'documents');
    DropZoneHelper.makeSortable('residential', 'documents');

    // after the order changes
    $('#residential .documents.sortable').sortable().bind('sortupdate', function(e, ui) {
        // array to store new order
        updated_order = []
        // set the updated positions
        DropZoneHelper.setPositions('residential', 'documents');

        // populate the updated_order array with the new task positions
        $('.doc').each(function(i){
          updated_order.push({ id: $(this).data('id'), position: i });
        });
        // send the updated order via ajax
        var unit_id = $('#residential').attr('data-unit-id');
        $.ajax({
          type: "PUT",
          url: '/residential_listings/' + unit_id + '/documents/sort',
          data: { order: updated_order }
        });
    });
  };

	ResidentialListings.initialize = function() {
		if (!$('#residential').length) {
			return;
		}
		ResidentialListings.passiveRealTimeUpdate();
		ResidentialListings.updateAnnouncements();


		// hide spinner on main index when first pulling up the page
		document.addEventListener("page:restore", function() {
		  Listings.hideSpinner();
		  ResidentialListings.passiveRealTimeUpdate();
		  ResidentialListings.updateAnnouncements();
		});
		Listings.hideSpinner();
		// // hide the spinner when we are editing, but switch to a new tab
		// $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
		//   Listings.hideSpinner();
		// });

		$('#residential a').click(function() {
			Listings.showSpinner();
		});

		// main index table
		ResidentialListings.setupSortableColumns();

		$('.close').click(function() {
			//console.log('detected click');
			Listings.hideSpinner();
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
	  $('#residential #roomsharing_filter').change(ResidentialListings.throttledSearch);
	  $('#residential #unassigned_filter').change(ResidentialListings.throttledSearch);
	  $('#residential #primary_agent_id').change(ResidentialListings.throttledSearch);

	  // remove individual features by clicking on 'x' button
	  //$('#residential .remove-unit-feature').click(ResidentialListings.removeUnitFeature);
	  //$('#residential .remove-building-feature').click(ResidentialListings.removeBuildingFeature);
	  $('#residential').on('click', '.remove-unit-feature',     ResidentialListings.removeUnitFeature);
	  $('#residential').on('click', '.remove-building-feature', ResidentialListings.removeBuildingFeature);
	  $('#residential').on('click', '.remove-neighborhood',     ResidentialListings.removeNeighborhood);

		// index page - selecting listings menu dropdown
		$('#residential #emailListings').click(Listings.sendMessage);
		$('#residential #assignListings').click(Listings.assignPrimaryAgent);
		$('#residential #unassignListings').click(Listings.unassignPrimaryAgent);
		$('#residential tbody').on('click', 'i', Listings.toggleListingSelection);
		$('#residential .select-all-listings').click(Listings.selectAllListings);
		$('#residential .selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Listings.indexMenuActions) Listings.indexMenuActions[action]();
		});

		// // make sure datepicker is formatted before setting initial date below
		// use in residential/edit, on photos tab
		$('.datepicker').datetimepicker({
		  viewMode: 'days',
		  format: 'MM/DD/YYYY',
		  allowInputToggle: true
		});
		var available_by = $('#residential .datepicker').attr('data-available-by');
		if (available_by) {
			$('#residential .datepicker').data("DateTimePicker").date(available_by);
		}

		if ($('#r-big-map').length > 0) {
      if(ResidentialListings.map) ResidentialListings.map.remove();
      if(CommercialListings.map) CommercialListings.map.remove();
      if(SalesListings.map) SalesListings.map.remove();
			// mapbox
			L.mapbox.accessToken = $('#mapbox-token').attr('data-mapbox-token');
	    ResidentialListings.map = L.mapbox.map('r-big-map', 'rakelblujeans.8594241c', { zoomControl: false })
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

	  // for drag n dropping photos/docs
		// disable auto discover
		Dropzone.autoDiscover = false;
	 	ResidentialListings.initializeImageDropzone();
	 	ResidentialListings.initializeDocumentsDropzone();

    // activate tooltips
    $('[data-toggle="tooltip"]').tooltip();

		ResidentialListings.detectPhoneNumbers();
	};

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
  	Listings.hideSpinner();
  }
});

$(document).ready(ResidentialListings.initialize);
