SalesListings = {};

(function() {
  SalesListings.timer;
  SalesListings.selectedNeighborhoodIds = null;
  SalesListings.selectedUnitAmenityIds = null;
  SalesListings.selectedBuildingAmenityIds = null;

  // SalesListings.wasAlreadyInitialized = function() {
  //   return !!$('.sales_listings').attr('initialized');
  // }

  // for searching on the index page
  SalesListings.doSearch = function (sortByCol, sortDirection) {
    Listings.showSpinner();

    var search_path = $('#sales-search-filters').attr('data-search-path');

    if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
      address: $('#sales #address').val(),
      unit: $('#sales #unit').val(),
      price_min: $('#sales #price_min').val(),
      price_max: $('#sales #price_max').val(),
      bed_min: $('#sales #bed_min').val(),
      bed_max: $('#sales #bed_max').val(),
      bath_min: $('#sales #bath_min').val(),
      bath_max: $('#sales #bath_max').val(),
      landlord: $('#sales #landlord').val(),
      pet_policy_shorthand: $('#sales #pet_policy_shorthand').val(),
      available_starting: $('#sales #available_starting').val(),
      available_before: $('#sales #available_before').val(),
      status: $('#sales #status').val(),
      features: $('#sales #features').val(),
      has_fee: $('#sales #has_fee').val(),
      // neighborhood_ids: SalesListings.selectedNeighborhoodIds,
      // unit_feature_ids: SalesListings.selectedUnitAmenityIds,
      // building_feature_ids: SalesListings.selectedBuildingAmenityIds,
      sort_by: sortByCol,
      direction: sortDirection,
    };

    if (SalesListings.selectedNeighborhoodIds && SalesListings.selectedNeighborhoodIds.length) {
        data.neighborhood_ids = SalesListings.selectedNeighborhoodIds;
      }
      if (SalesListings.selectedUnitAmenityIds && SalesListings.selectedUnitAmenityIds.length) {
        data.unit_feature_ids = SalesListings.selectedUnitAmenityIds;
      }
      if (SalesListings.selectedBuildingAmenityIds && SalesListings.selectedBuildingAmenityIds.length) {
        data.building_feature_ids = SalesListings.selectedBuildingAmenityIds;
      }

    var searchParams = [];
    for(var key in data) {
      if (data.hasOwnProperty(key) && data[key]) {
        searchParams.push(key + "=" + data[key]);
      }
    }
    window.location.search = searchParams.join('&');
  };

  SalesListings.clearTimer = function() {
    if (SalesListings.timer) {
      clearTimeout(SalesListings.timer);
    }
  };

  // SalesListings.enablePassiveUpdates = function() {
    // if (!Common.onMobileDevice()) {
    //   SalesListings.passiveRealTimeUpdate();
    // }
  // }

  // if a user remains on this page for an extended amount of time,
  // refresh the page every so often. We want to make sure they are
  // always viewing the latest data.
  // SalesListings.passiveRealTimeUpdate = function() {
  //   SalesListings.clearTimer();
  //   // update every few minutes
   //  SalesListings.timer = setTimeout(SalesListings.doSearch, 60 * 10 * 1000);
  // };

  // search as user types
  SalesListings.throttledSearch = function () {
    //clear any interval on key up
    SalesListings.clearTimer();
    SalesListings.timer = setTimeout(SalesListings.doSearch, 500);
  };

  // change enter key to tab
  SalesListings.preventEnter = function (event) {
    if (event.keyCode == 13) {
      //$('#checkbox_active').focus();
      return false;
    }
  };

  // for giant map
  SalesListings.buildContentString = function (key, info) {
    var slideshowContent = '';
    var contentString = '<strong>' + key + '</strong><br />';

    var firstImageAdded = false;
    var imgCount = 0;
    for (var i=0; i<info['units'].length; i++) {

      unit = info['units'][i];

      if (unit.image) {
        slideshowContent += '<div class="image' + (!firstImageAdded ? ' active' : '') + '">' +
            '<a href="https://myspace-realty-monster.herokuapp.com/sales_listings/'+ unit.id +
            '"><img src="' + unit.image + '" /></a>' +
            '</div>';
        firstImageAdded = true;
        imgCount++;
      }

      var shouldHighlightRow = imgCount == 1 && info['units'].length > 1;
      contentString += '<div class="contentRow' + (shouldHighlightRow ? ' active' : '') +'">'
        + '<a href="https://myspace-realty-monster.herokuapp.com/sales_listings/'
        + unit.id + '">#' + unit.building_unit + ' ' +
        + unit.beds + ' bd / '
        + unit.baths + ' baths $' + unit.rent + '</a></div>';
      if (i == 5) {
        contentString += '<div class="contentRow"><a href="https://myspace-realty-monster.herokuapp.com/buildings/'
          + info['building_id'] + '">View more...</a></div>';
        break;
      }
    }

    output =
      '<div class="slideshow">' +
        slideshowContent +
      '</div>';
    if (imgCount > 1) {
      output += '<div class="cycle">' +
        '<a href="#" class="prev">&laquo; Previous</a>' +
        '<a href="#" class="next">Next &raquo;</a>' +
        '</div>';
    }
    output += '<div class="content">' +
      contentString +
      '</div>';
    return '<div class="popup">' + output + '</div>';
  };

  SalesListings.sortOnColumnClick = function() {
    $('#sales .th-sortable').click(function(e) {
      Common.sortOnColumnClick($(this), SalesListings.doSearch);
    });
  };

  SalesListings.initializeDocumentsDropzone = function() {
    // grap our upload form by its id
    $("#sunit-dropzone-docs").dropzone({
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
        $.getScript('/sales_listings/' + response.sunitID + '/refresh_documents')
        file.previewElement.remove();
      },
      //when the remove button is clicked
      removedfile: function(file){
        // grap the id of the uploaded file we set earlier
        var id = $(file.previewTemplate).find('.dz-remove').attr('id');
        var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
        DropZoneHelper.removeDocument(id, unit_id, 'sales_listings');
        file.previewElement.remove();
      }
    });

    DropZoneHelper.updateRemoveDocLinks('sales', 'sales_listings');

    DropZoneHelper.setPositions('sales', 'documents');
    DropZoneHelper.makeSortable('sales', 'documents');

    // after the order changes
    $('#sales .documents.sortable').sortable().bind('sortupdate', function(e, ui) {
        // array to store new order
        updated_order = []
        // set the updated positions
        DropZoneHelper.setPositions('sales', 'documents');

        // populate the updated_order array with the new task positions
        $('.doc').each(function(i){
          updated_order.push({ id: $(this).data('id'), position: i });
        });
        // send the updated order via ajax
        var unit_id = $('#sales').attr('data-unit-id');
        $.ajax({
          type: "PUT",
          url: '/sales_listings/' + unit_id + '/documents/sort',
          data: { order: updated_order }
        });
    });
  };

  SalesListings.initializeImageDropzone = function() {
    // grap our upload form by its id
    $("#sunit-dropzone").dropzone({
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
        $.getScript('/sales_listings/' + response.sunitID + '/refresh_images')
        file.previewElement.remove();
      },
      //when the remove button is clicked
      removedfile: function(file){
        // grap the id of the uploaded file we set earlier
        var id = $(file.previewTemplate).find('.dz-remove').attr('id');
        var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
        DropZoneHelper.removeImage(id, unit_id, 'sales_listings');
        file.previewElement.remove();
      }
    });

    DropZoneHelper.updateRemoveImgLinks('sales', 'sales_listings');

    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active');

    DropZoneHelper.setPositions('sales', 'images');
    DropZoneHelper.makeSortable('sales', 'images');

    // after the order changes
    $('#sales .sortable').sortable().bind('sortupdate', function(e, ui) {
        // array to store new order
        updated_order = []
        // set the updated positions
        DropZoneHelper.setPositions('sales', 'images');

        // populate the updated_order array with the new task positions
        $('.img').each(function(i) {
          updated_order.push({ id: $(this).data('id'), position: i });
        });
        //console.log(updated_order);
        // send the updated order via ajax
        var unit_id = $('#sales').attr('data-unit-id');
        $.ajax({
          type: "PUT",
          url: '/sales_listings/' + unit_id + '/unit_images/sort',
          data: { order: updated_order }
        });
    });
  };

  // SalesListings.updateOverviewMap = function(in_data) {
  //  SalesListings.overlays.clearLayers();
 //    var markers = new L.MarkerClusterGroup({
 //     maxClusterRadius: 30 // lean towards showing more individual markers
 //    }).addTo(SalesListings.overlays);

 //    var dataPoints;
  //   // if updating from an ajax call, in_data will hava content.
  //   // we load data from a data attribute on page load, but that remains cached forever -
  //   // it will not update with subsequent ajax calls.
  //   if (in_data) {
  //    dataPoints = JSON.parse(in_data);
  //   } else {
  //    dataPoints = JSON.parse($('#s-big-map').attr('data-map-points'));
  //   }
  //   Object.keys(dataPoints).forEach(function(key, index) {
  //     // draw each marker + load with data
  //     var info = dataPoints[key];
  //     var content = SalesListings.buildContentString(key, info);
  //     var marker = L.marker(new L.LatLng(info.lat, info.lng), {
  //       icon: L.mapbox.marker.icon({
  //        'marker-size': 'small',
  //        'marker-color': '#f86767'
  //       }),
  //       'title': key,
  //     });
  //     marker.bindPopup(content);
 //      markers.addLayer(marker);
  //  });

 //    if (dataPoints.length) {
 //       SalesListings.map.addLayer(markers);
 //      SalesListings.map.fitBounds(markers.getBounds());
 //    }
  // };

  SalesListings.commissionAmount = function() {
    if($('#sales_listing_cyof_true').is(":checked")){
      $("#sales_listing_commission_amount").val('0');
      $("#sales_listing_commission_amount").attr("readonly", "readonly");
    }
    $('input[name="sales_listing[cyof]"]').change(function(){
      if($(this).attr("id")=="sales_listing_cyof_true"){
        $("#sales_listing_commission_amount").val('0');
        $("#sales_listing_commission_amount").attr("readonly", "readonly");
      }
      else
      {
        $("#sales_listing_commission_amount").val('');
        $("#sales_listing_commission_amount").removeAttr("readonly");
      }
    });
  };

  SalesListings.rlsnyValidation = function() {
    if($('#sales_listing_rlsny').is(":checked")){
      $("#sales_listing_floor").attr("required", true);
      $("#sales_listing_total_room_count").attr("required", true);
      $("#sales_listing_condition").attr("required", true);
      $("#sales_listing_showing_instruction").attr("required", true);
      $("#sales_listing_commission_amount").attr("required", true);

      $('label[for="sales_listing_floor"]').addClass("required");
      $('label[for="sales_listing_total_room_count"]').addClass("required");
      $('label[for="sales_listing_condition"]').addClass("required");
      $('label[for="sales_listing_showing_instruction"]').addClass("required");
      $('label[for="sales_listing_commission_amount"]').addClass("required");
      $('label[for="sales_listing_cyof"]').addClass("required");
      $('label[for="sales_listing_share_with_brokers"]').addClass("required");
    }
    $('input[name="sales_listing[rlsny]"]').change(function(){
      if($(this).is(":checked")){
        $("#sales_listing_floor").attr("required", true);
        $("#sales_listing_total_room_count").attr("required", true);
        $("#sales_listing_condition").attr("required", true);
        $("#sales_listing_showing_instruction").attr("required", true);
        $("#sales_listing_commission_amount").attr("required", true);

        $('label[for="sales_listing_floor"]').addClass("required");
        $('label[for="sales_listing_total_room_count"]').addClass("required");
        $('label[for="sales_listing_condition"]').addClass("required");
        $('label[for="sales_listing_showing_instruction"]').addClass("required");
        $('label[for="sales_listing_commission_amount"]').addClass("required");
        $('label[for="sales_listing_cyof"]').addClass("required");
        $('label[for="sales_listing_share_with_brokers"]').addClass("required");
      }
      else
      {
        $("#sales_listing_floor").removeAttr("required");
        $("#sales_listing_total_room_count").removeAttr("required");
        $("#sales_listing_condition").removeAttr("required");
        $("#sales_listing_showing_instruction").removeAttr("required");
        $("#sales_listing_commission_amount").removeAttr("required");

        $('label[for="sales_listing_floor"]').removeClass("required");
        $('label[for="sales_listing_total_room_count"]').removeClass("required");
        $('label[for="sales_listing_condition"]').removeClass("required");
        $('label[for="sales_listing_showing_instruction"]').removeClass("required");
        $('label[for="sales_listing_commission_amount"]').removeClass("required");
        $('label[for="sales_listing_cyof"]').removeClass("required");
        $('label[for="sales_listing_share_with_brokers"]').removeClass("required");
      }
    });
  };

  SalesListings.initEditor = function() {
    var available_by = $('#sales .datepicker').attr('data-available-by');
    if (available_by) {
      $('#sales .datepicker').data("DateTimePicker").date(available_by);
    }

    // for address autocompletion in form
    var bldg_address = $('#map-canvas').attr('data-address') ? $('#map-canvas').attr('data-address') : 'New York, NY, USA';
    $(".autocomplete-input").geocomplete({
      map: "#map-canvas",
      location: bldg_address,
      details: ".details"
    }).bind("geocode:result", function(event, result) {
      if (this.value == "New York, NY, USA") {
        this.value = '';
      }

      // update neighborhood options from google results
      var sublocality = '';
      for (var i =0; i<result.address_components.length; i++) {
        if (result.address_components[i].types &&
            result.address_components[i].types[1] === "sublocality") {
          sublocality = result.address_components[i]["short_name"];
        }
      }

      // if no neighborhood already set, update neighborhood from google results
      //if ($('#neighborhood').val() === null) {
        $.ajax({
          type: "GET",
          url: '/sales_listings/neighborhood_options',
          data: {
            sublocality: sublocality,
          },
          dataType: "script",
          success: function(data) {
            for (var i =0; i<result.address_components.length; i++) {
              if (result.address_components[i].types[0] === "neighborhood") {
                var nabe = result.address_components[i].short_name;
                $('#neighborhood').val(nabe);
              }
            }
          }
        });
      //}
    }).bind("geocode:error", function(event, result){
      // console.log("[ERROR]: " + result);
    });

    // for drag n dropping photos
    // disable auto discover
    Dropzone.autoDiscover = false;
    SalesListings.initializeImageDropzone();
    SalesListings.initializeDocumentsDropzone();

    SalesListings.commissionAmount();
    SalesListings.rlsnyValidation();
  };

  SalesListings.initIndex = function() {
    Listings.hideSpinner();
    $('#sales a').click(function() {
      if ($(this).text().toLowerCase().indexOf('csv') === -1) {
        Listings.showSpinner();
      }
    });

    // main index table
    SalesListings.sortOnColumnClick();
    Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="updated_at"]'), 'desc')
    }

    $('.close').click(function() {
      Listings.hideSpinner();
    });

    $('#neighborhood-select-multiple').change(SalesListings.throttledSearch);
    $('#unit-amenities-select-multiple').change(SalesListings.throttledSearch);
    $('#building-amenities-select-multiple').change(SalesListings.throttledSearch);

    RHMapbox.initMapbox('s-big-map', SalesListings.buildContentString);

    // index filtering
    $('#sales input').keydown(SalesListings.preventEnter);
    // $('#sales #address').bind('railsAutocomplete.select', SalesListings.throttledSearch);
    // $('#sales #address').change(SalesListings.throttledSearch);
    // $('#sales #unit').change(SalesListings.throttledSearch);
    // $('#sales #price_min').change(SalesListings.throttledSearch);
    // $('#sales #price_max').change(SalesListings.throttledSearch);
    // $('#sales #bed_min').change(SalesListings.throttledSearch);
    // $('#sales #bed_max').change(SalesListings.throttledSearch);
    // $('#sales #bath_min').change(SalesListings.throttledSearch);
    // $('#sales #bath_max').change(SalesListings.throttledSearch);
    // $('#sales #landlord').bind('railsAutocomplete.select', SalesListings.throttledSearch);
    // $('#sales #landlord').change(SalesListings.throttledSearch);
    // $('#sales #available_starting').blur(SalesListings.throttledSearch);
    // $('#sales #available_before').blur(SalesListings.throttledSearch);
    // $('#sales #pet_policy_shorthand').change(SalesListings.throttledSearch);
    // $('#sales #status').change(SalesListings.throttledSearch);
    // $('#sales #features').change(SalesListings.throttledSearch);
    // $('#sales #has_fee').change(SalesListings.throttledSearch);
    // $('#sales #neighborhood_ids').change(SalesListings.throttledSearch);
    // $('#sales #unit_feature_ids').change(SalesListings.throttledSearch);
    // $('#sales #building_feature_ids').change(SalesListings.throttledSearch);
    $('#sales-search-trigger').click(function(e) {
      SalesListings.doSearch();
      e.preventDefault();
    });

    SalesListings.selectedNeighborhoodIds = Common.getURLParameterByName('neighborhood_ids');
    if (SalesListings.selectedNeighborhoodIds) {
      SalesListings.selectedNeighborhoodIds =
          SalesListings.selectedNeighborhoodIds.split(',');
    }

    $('#neighborhood-select-multiple').selectize({
      plugins: ['remove_button'],
      hideSelected: true,
      maxItems: 100,
      items: SalesListings.selectedNeighborhoodIds,
      onChange: function(value) {
        SalesListings.selectedNeighborhoodIds = value;
      }
    });

    SalesListings.selectedUnitAmenityIds = Common.getURLParameterByName('unit_feature_ids');
    if (SalesListings.selectedUnitAmenityIds) {
      SalesListings.selectedUnitAmenityIds =
          SalesListings.selectedUnitAmenityIds.split(',');
    }

    if (!$('#unit-amenities-select-multiple')[0].selectize) {
      $('#unit-amenities-select-multiple').selectize({
        plugins: ['remove_button'],
        hideSelected: true,
        maxItems: 100,
        items: SalesListings.selectedUnitAmenityIds,
        onChange: function(value) {
          SalesListings.selectedUnitAmenityIds = value;
        }
      });
    }

    SalesListings.selectedBuildingAmenityIds = Common.getURLParameterByName('building_feature_ids');
    if (SalesListings.selectedBuildingAmenityIds) {
      SalesListings.selectedBuildingAmenityIds =
          SalesListings.selectedBuildingAmenityIds.split(',');
    }

    if (!$('#building-amenities-select-multiple')[0].selectize) {
      $('#building-amenities-select-multiple').selectize({
        plugins: ['remove_button'],
        hideSelected: true,
        maxItems: 100,
        items: SalesListings.selectedBuildingAmenityIds,
        onChange: function(value) {
          SalesListings.selectedBuildingAmenityIds = value;
        }
      });
    }

    var available_by = $('#sales .datepicker').attr('data-available-by');
    if (available_by) {
      $('#sales .datepicker').data("DateTimePicker").date(available_by);
    }

    // index page - selecting listings menu dropdown
    $('#sales #emailListings').click(Listings.sendMessage);
    $('#sales tbody').off('click', 'i', Listings.toggleListingSelection);
    $('#sales tbody').on('click', 'i', Listings.toggleListingSelection);
    $('#sales .select-all-listings').off('click', Listings.selectAllListings);
    $('#sales .select-all-listings').on('click', Listings.selectAllListings);
    $('#sales .selected-listings-menu').on('click', 'a', function() {
      var action = $(this).data('action');
      if (action in Listings.indexMenuActions) Listings.indexMenuActions[action]();
    });

    // SalesListings.passiveRealTimeUpdate();
  };

  SalesListings.initShow = function() {
    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active');
  };

  SalesListings.ready = function() {
    SalesListings.clearTimer();

    // if (!SalesListings.wasAlreadyInitialized()) {
      var editPage = $('.sales_listings.edit').length;
      var newPage = $('.sales_listings.new').length;
      var indexPage = $('.sales_listings.index').length;

      // new and edit pages both render the same form template, so init them using the same code
      if (editPage || newPage) {
        SalesListings.initEditor();
      } else if (indexPage) {
        SalesListings.initIndex();
      } else {
        SalesListings.initShow();
      }
    // };
  }
})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    Listings.hideSpinner();
  }
});

document.addEventListener('turbolinks:load', SalesListings.ready);

// document.addEventListener("turbolinks:before-cache", function() {
//   $('.sales_listings').attr('initialized', 'true');
// })
