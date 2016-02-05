CommercialListings = {};

(function() {

  CommercialListings.updatePropertySubTypes = function (ptype) {
    var id = $('#commercial').attr('data-unit-id');
    $.ajax({
      url: "/commercial_listings/update_subtype",
      data: {
          property_type: ptype,
          id: id
      },
      dataType: "script",
    });
  };

  CommercialListings.doSearch = function(sortByCol, sortDirection) {
    // console.log('before', $('#commercial #neighborhood_ids').val());
    Listings.showSpinner();

    // sanitize invalid input before submitting
    if ($('#commercial #neighborhood_ids').val() == "{:id=>\"neighborhood_ids\"}") {
      $('#commercial #neighborhood_ids').val('');
    }

    var search_path = $('#com-search-filters').attr('data-search-path');

    if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
        address: $('#commercial #address').val(),
        rent_min: $('#commercial #rent_min').val(),
        rent_max: $('#commercial #rent_max').val(),
        sq_footage_min: $('#commercial #sq_footage_min').val(),
        sq_footage_max: $('#commercial #sq_footage_max').val(),
        landlord: $('#commercial #landlord').val(),
        status: $('#commercial #status').val(),
        commercial_property_type_id: $('#commercial #commercial_property_type_id').val(),
        listing_id: $('#commercial #listing_id').val(),
        neighborhood_ids: $('#commercial #neighborhood_ids').val(),
        primary_agent_id:  $('#commercial #primary_agent_id').val(),
        sort_by: sortByCol,
        direction: sortDirection,
      };

    var searchParams = [];
    for(var key in data) {
      if (data.hasOwnProperty(key) && data[key]) {
        searchParams.push(key + "=" + data[key]);
      }
    }
    window.location.search = searchParams.join('&');

    CommercialListings.passiveRealTimeUpdate();
  };

  CommercialListings.sortOnColumnClick = function() {
    $('#commercial .th-sortable').click(function(e) {
      Common.sortOnColumnClick($(this), CommercialListings.doSearch);
    });
  };

  CommercialListings.removeNeighborhood = function (event) {
    event.preventDefault();
    var feature_id = $(this).attr('data-id');
    var idx = $('#commercial #neighborhood_ids').val().indexOf(feature_id);
    $('#commercial #neighborhood_ids').val( $('#commercial #neighborhood_ids').val().replace(feature_id, '') );
    $(this).remove();
    CommercialListings.throttledSearch();
  };

  // search as user types
  CommercialListings.timer;

  CommercialListings.clearTimer = function() {
    if (CommercialListings.timer) {
      clearTimeout(CommercialListings.timer);
    }
  };

  // if a user remains on this page for an extended amount of time,
  // refresh the page every so often. We want to make sure they are
  // always viewing the latest data.
  CommercialListings.passiveRealTimeUpdate = function() {
    if ($('#commercial').length > 0) {
      CommercialListings.clearTimer();
      // update every few minutes
      CommercialListings.timer = setTimeout(CommercialListings.doSearch, 60 * 3 * 1000);
    }
  };

  // search as user types
  CommercialListings.throttledSearch = function () {
    CommercialListings.clearTimer();
    //clear any interval on key up
    timer = setTimeout(CommercialListings.doSearch, 500);
  };

  // change enter key to tab
  CommercialListings.preventEnter = function(event) {
    if (event.keyCode == 13) {
      return false;
    }
  };

  CommercialListings.map;
  CommercialListings.overlays;

  // for giant google map
  CommercialListings.buildContentString = function (key, info) {
    var contentString = '<strong>' + key + '</strong><br />'; //<hr />';
    for (var i=0; i<info['units'].length; i++) {
      contentString += '<a href="https://myspace-realty-monster.herokuapp.com/commercial_listings/' + info['units'][i].id + '">#' + info['units'][i].building_unit + '</a> ' + info['units'][i].beds + ' bd / '
        + info['units'][i].baths + ' baths $' + info['units'][i].rent + '<br />';
      if (i == 5) {
        contentString += '<a href="https://myspace-realty-monster.herokuapp.com/commercial_listings?building_id=' + info['building_id'] + '">View more...</a>';
        break;
      }
    }
    return contentString;
  };

  CommercialListings.updateOverviewMap = function(in_data) {
    CommercialListings.overlays.clearLayers();
    var markers = new L.MarkerClusterGroup({
      maxClusterRadius: 30 // lean towards showing more individual markers
    }).addTo(CommercialListings.overlays);//{ showCoverageOnHover: false });

    var dataPoints;
    // if updating from an ajax call, in_data will hava content.
    // we load data from a data attribute on page load, but that remains cached forever -
    // it will not update with subsequent ajax calls.
    if (in_data) {
      dataPoints = JSON.parse(in_data);
    } else {
      dataPoints = JSON.parse($('#c-big-map').attr('data-map-points'));
    }

    Object.keys(dataPoints).forEach(function(key, index) {
      // draw each marker + load with data
      var info = dataPoints[key];
      var content = CommercialListings.buildContentString(key, info);
      var marker = L.marker(new L.LatLng(info.lat, info.lng), {
        icon: L.mapbox.marker.icon({
          'marker-size': 'small',
          'marker-color': '#f86767'
        }),
        'title': key,
      });
      marker.bindPopup(content);
      markers.addLayer(marker);
    });

    if (dataPoints.length) {
      CommercialListings.map.addLayer(markers);
      CommercialListings.map.fitBounds(markers.getBounds());
    }
  };

  CommercialListings.initializeDocumentsDropzone = function() {
    // grap our upload form by its id
    $("#cunit-dropzone-docs").dropzone({
      // show remove links on each image upload
      addRemoveLinks: true,
      // if the upload was successful
      success: function(file, response){
        // find the remove button link of the uploaded file and give it an id
        // based of the fileID response from the server
        $(file.previewTemplate).find('.dz-remove').attr('id', response.fileID);
        $(file.previewTemplate).find('.dz-remove').attr('unit_id', response.cunitID);
        // add the dz-success class (the green tick sign)
        $(file.previewElement).addClass("dz-success");
        $.getScript('/commercial_listings/' + response.cunitID + '/refresh_documents')
        file.previewElement.remove();
      },
      //when the remove button is clicked
      removedfile: function(file){
        // grap the id of the uploaded file we set earlier
        var id = $(file.previewTemplate).find('.dz-remove').attr('id');
        var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
        DropZoneHelper.removeDocument(id, unit_id, 'commercial_listings');
        file.previewElement.remove();
      }
    });

    DropZoneHelper.updateRemoveDocLinks('commercial', 'commercial_listings');

    // $('.carousel-indicators > li:first-child').addClass('active');
    // $('.carousel-inner > .item:first-child').addClass('active');

    DropZoneHelper.setPositions('commercial', 'documents');
    DropZoneHelper.makeSortable('commercial', 'documents');

    // after the order changes
    $('#commercial .documents.sortable').sortable().bind('sortupdate', function(e, ui) {
        // array to store new order
        updated_order = []
        // set the updated positions
        DropZoneHelper.setPositions('commercial', 'documents');

        // populate the updated_order array with the new task positions
        $('.doc').each(function(i){
          updated_order.push({ id: $(this).data('id'), position: i });
        });
        // send the updated order via ajax
        var unit_id = $('#commercial').attr('data-unit-id');
        $.ajax({
          type: "PUT",
          url: '/commercial_listings/' + unit_id + '/documents/sort',
          data: { order: updated_order }
        });
    });
  };

  CommercialListings.initializeImageDropzone = function() {
    // grap our upload form by its id
    $("#cunit-dropzone").dropzone({
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
        $(file.previewTemplate).find('.dz-remove').attr('unit_id', response.cunitID);
        // add the dz-success class (the green tick sign)
        $(file.previewElement).addClass("dz-success");
        $.getScript('/commercial_listings/' + response.cunitID + '/refresh_images')
        file.previewElement.remove();
      },
      //when the remove button is clicked
      removedfile: function(file){
        // grap the id of the uploaded file we set earlier
        var id = $(file.previewTemplate).find('.dz-remove').attr('id');
        var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
        DropZoneHelper.removeImage(id, unit_id, 'commercial_listings');
        file.previewElement.remove();
      }
    });

    DropZoneHelper.updateRemoveImgLinks('commercial', 'commercial_listings');

    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active');

    DropZoneHelper.setPositions('commercial', 'images');
    DropZoneHelper.makeSortable('commercial', 'images');

    // after the order changes
    $('#commercial .sortable').sortable().bind('sortupdate', function(e, ui) {
        // array to store new order
        updated_order = []
        // set the updated positions
        DropZoneHelper.setPositions('commercial', 'images');

        // populate the updated_order array with the new task positions
        $('.img').each(function(i) {
          updated_order.push({ id: $(this).data('id'), position: i });
        });
        // send the updated order via ajax
        var unit_id = $('#commercial').attr('data-unit-id');
        $.ajax({
          type: "PUT",
          url: '/commercial_listings/' + unit_id + '/unit_images/sort',
          data: { order: updated_order }
        });
    });
  };

  CommercialListings.initEditor = function() {
    // edit/new form
    $('#commercial_listing_property_type').change(function(e) {
      var optionSelected = $("option:selected", this);
      var textSelected   = optionSelected.text();
      CommercialListings.updatePropertySubTypes(textSelected);
    });

    var ptype = $('#commercial').attr('data-property-type');
    if (ptype) {
      CommercialListings.updatePropertySubTypes(ptype);
    }

    var available_by = $('#commercial .datepicker').attr('data-available-by');
    if (available_by) {
      $('#commercial .datepicker').data("DateTimePicker").date(available_by);
    }

    // for drag n dropping photos/documents
    // disable auto discover
    Dropzone.autoDiscover = false;
    CommercialListings.initializeImageDropzone();
    CommercialListings.initializeDocumentsDropzone();
  }

  CommercialListings.initIndex = function() {
    document.addEventListener("page:restore", function() {
      CommercialListings.passiveRealTimeUpdate();
      Listings.hideSpinner();
    });
    Listings.hideSpinner();
    $('#commercial a').click(function() {
      Listings.showSpinner();
    });

    // main index table
    CommercialListings.sortOnColumnClick();
    Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="updated_at"]'), 'desc')
    }



    if ($('#c-big-map').length > 0) {
      if(ResidentialListings.map) ResidentialListings.map.remove();
      if(CommercialListings.map) CommercialListings.map.remove();
      if(SalesListings.map) SalesListings.map.remove();
      // mapbox
      L.mapbox.accessToken = $('#mapbox-token').attr('data-mapbox-token');
      CommercialListings.map = L.mapbox.map('c-big-map', 'rakelblujeans.8594241c', { zoomControl: false })
          .setView([40.6739591, -73.9570342], 13);

      new L.Control.Zoom({ position: 'topright' }).addTo(CommercialListings.map);
      CommercialListings.overlays = L.layerGroup().addTo(CommercialListings.map);
      CommercialListings.updateOverviewMap();
    }

    // google map on show page
    var bldg_address = $('#map_canvas').attr('data-address') ? $('#map_canvas').attr('data-address') : 'New York, NY, USA';
    $("#cunit-panel").geocomplete({
      map: "#map_canvas",
      location: bldg_address,
      details: ".details"
    }).bind("geocode:result", function(event, result){
      //console.log(result);
    }).bind("geocode:error", function(event, result){
      //console.log("[ERROR]: " + result);
    });

    $('#commercial input').keydown(CommercialListings.preventEnter);
    $('#commercial #address').bind('railsAutocomplete.select', CommercialListings.throttledSearch);
    $('#commercial #address').change(CommercialListings.throttledSearch);
    $('#commercial #rent_min').change(CommercialListings.throttledSearch);
    $('#commercial #sq_footage_min').change(CommercialListings.throttledSearch);
    $('#commercial #sq_footage_max').change(CommercialListings.throttledSearch);
    $('#commercial #rent_max').change(CommercialListings.throttledSearch);
    $('#commercial #landlord').bind('railsAutocomplete.select', CommercialListings.throttledSearch);
    $('#commercial #landlord').change(CommercialListings.throttledSearch);
    $('#commercial #status').change(CommercialListings.throttledSearch);
    $('#commercial #neighborhood_ids').change(CommercialListings.throttledSearch);
    $('#commercial #commercial_property_type_id').change(CommercialListings.throttledSearch);
    $('#commercial #listing_id').change(CommercialListings.throttledSearch);
    $('#commercial #primary_agent_id').change(CommercialListings.throttledSearch);

    $('#commercial').on('click', '.remove-neighborhood', CommercialListings.removeNeighborhood);

    // index page - selecting listings menu dropdown
    $('#commercial #emailListings').click(Listings.sendMessage);
    $('#commercial tbody').on('click', 'i', Listings.toggleListingSelection);
    $('#commercial .select-all-listings').click(Listings.selectAllListings);
    $('#commercial .selected-listings-menu').on('click', 'a', function() {
      var action = $(this).data('action');
      if (action in Listings.indexMenuActions) Listings.indexMenuActions[action]();
    });

    CommercialListings.passiveRealTimeUpdate();
  }

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    Listings.hideSpinner();
  }
});

$(document).ready(function() {
  var url = window.location.pathname;
  var commercial = url.indexOf('commercial_listings') > -1;
  var editPage = url.indexOf('edit') > -1;
  var newPage = url.indexOf('new') > -1;
  if (commercial) {
    // new and edit pages both render the same form template, so init them using the same code
    if (editPage || newPage) {
      CommercialListings.initEditor();
    } else {
      CommercialListings.initIndex();
    }
  }
});
