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
    // don't trigger this on the show page (<URL>/commercial_listings/<ID<)
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

  // for giant google map
  CommercialListings.buildContentString = function (key, info) {
    // var contentString = '<strong>' + key + '</strong><br />'; //<hr />';
    // for (var i=0; i<info['units'].length; i++) {
    //   contentString += '<a href="https://myspace-realty-monster.herokuapp.com/commercial_listings/' + info['units'][i].id + '">#' + info['units'][i].building_unit + '</a> ' + info['units'][i].beds + ' bd / '
    //     + info['units'][i].baths + ' baths $' + info['units'][i].rent + '<br />';
    //   if (i == 5) {
    //     contentString += '<a href="https://myspace-realty-monster.herokuapp.com/commercial_listings?building_id=' + info['building_id'] + '">View more...</a>';
    //     break;
    //   }
    // }
    // return contentString;


    var slideshowContent = '';
    var contentString = '<strong>' + key + '</strong><br />';

    var firstImageAdded = false;
    var imgCount = 0;
    for (var i=0; i<info['units'].length; i++) {

      unit = info['units'][i];

      if (unit.image) {
        slideshowContent += '<div class="image' + (!firstImageAdded ? ' active' : '') + '">' +
            '<a href="https://myspace-realty-monster.herokuapp.com/commercial_listings/' +
            unit.id + '">' +
            '<img src="' + unit.image + '" />' +
            '</div>';
        firstImageAdded = true;
        imgCount++;
      }

      var shouldHighlightRow = imgCount == 1 && info['units'].length > 1;
      contentString += '<div class="contentRow' + (shouldHighlightRow ? ' active' : '') +'">' +
          '<a href="https://myspace-realty-monster.herokuapp.com/commercial_listings/' +
          unit.id + '">#' + unit.property_type + '</a> ' +
          unit.sq_footage + ' Sq Ft, $' +
          unit.rent + '</div>';
      if (i == 5) {
        contentString += '<div class="contentRow">' +
        '<a href="https://myspace-realty-monster.herokuapp.com/commercial_listings?building_id='
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

    RHMapbox.initMapbox('c-big-map', CommercialListings.buildContentString);

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

    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active');
  }

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    Listings.hideSpinner();
  }
});

$(document).ready(function() {
  CommercialListings.clearTimer();

  var url = window.location.pathname;
  var commercial = url.indexOf('commercial_listings') > -1;
  var editPage = url.indexOf('edit') > -1;
  var newPage = url.indexOf('new') > -1;
  // var showPage = url.end
  if (commercial) {
    // new and edit pages both render the same form template, so init them using the same code
    if (editPage || newPage) {
      CommercialListings.initEditor();
    } else {
      CommercialListings.initIndex();
    }
  }
});
