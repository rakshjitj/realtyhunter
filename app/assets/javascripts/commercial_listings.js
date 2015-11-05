CommercialUnits = {};

(function() {

  CommercialUnits.updatePropertySubTypes = function (ptype) {
    var id = $('#commercial').attr('data-cunit-id');
    //console.log('got path ', id);
    $.ajax({
      url: "/commercial_listings/update_subtype",
      data: {
          property_type: ptype,
          id: id
      },
      dataType: "script",
    });
  };

  CommercialUnits.doSearch = function(sort_by_col, sort_direction) {
    Listings.showSpinner();

    // sanitize invalid input before submitting
    if ($('#commercial #neighborhood_ids').val() == "{:id=>\"neighborhood_ids\"}") {
      $('#commercial #neighborhood_ids').val('');
    }

    var search_path = $('#com-search-filters').attr('data-search-path');
    
    $.ajax({
      url: search_path, 
      data: {
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
        sort_by: sort_by_col,
        direction: sort_direction,
      },
      dataType: "script",
      success: function(data) {
        Listings.hideSpinner();
      },
      error: function(data) {
        Listings.hideSpinner();
      }
    });

    CommercialUnits.passiveRealTimeUpdate();
  };

  CommercialUnits.setupSortableColumns = function() {
    $('#commercial .th-sortable').click(function(e) {
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
      CommercialUnits.doSearch(sort_by_col, sort_direction);
    });
  };

  // search as user types
  CommercialUnits.timer;

  CommercialUnits.clearTimer = function() {
    if (CommercialUnits.timer) {
      clearTimeout(CommercialUnits.timer);
    }
  };

  // if a user remains on this page for an extended amount of time,
  // refresh the page every so often. We want to make sure they are
  // always viewing the latest data.
  CommercialUnits.passiveRealTimeUpdate = function() {
    SalesListings.clearTimer();
    ResidentialListings.clearTimer();
    CommercialUnits.clearTimer();
    Announcements.clearTimer();
    // update every few minutes
    CommercialUnits.timer = setTimeout(CommercialUnits.doSearch, 60 * 3 * 1000);
  };

  // search as user types
  CommercialUnits.throttledSearch = function () {
    SalesListings.clearTimer();
    ResidentialListings.clearTimer();
    CommercialUnits.clearTimer();
    Announcements.clearTimer();
    //clear any interval on key up
    timer = setTimeout(CommercialUnits.doSearch, 500);
  };
  
  // change enter key to tab
  CommercialUnits.preventEnter = function(event) {
    if (event.keyCode == 13) {
      return false;
    }
  };

  CommercialUnits.initializeDocumentsDropzone = function() {
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

  CommercialUnits.initializeImageDropzone = function() {
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
        //console.log(updated_order);
        // send the updated order via ajax
        var unit_id = $('#commercial').attr('data-unit-id');
        console.log(unit_id);
        $.ajax({
          type: "PUT",
          url: '/commercial_listings/' + unit_id + '/unit_images/sort',
          data: { order: updated_order }
        });
    });
  };

  //call when typing or enter or focus leaving
  CommercialUnits.initialize = function () {
    document.addEventListener("page:restore", function() {
      CommercialUnits.passiveRealTimeUpdate();
      Listings.hideSpinner();
    });
    Listings.hideSpinner();
    $('#commercial a').click(function() {
      Listings.showSpinner();
    });

    // main index table
    CommercialUnits.setupSortableColumns();

    // edit/new form
    $('#commercial_listing_property_type').change(function(e) {
      var optionSelected = $("option:selected", this);
      var textSelected   = optionSelected.text();
      console.log(textSelected);
      CommercialUnits.updatePropertySubTypes(textSelected);
    });

    var ptype = $('#commercial').attr('data-property-type');
    if (ptype) {
      CommercialUnits.updatePropertySubTypes(ptype);
    }	

    var available_by = $('#commercial .datepicker').attr('data-available-by');
    if (available_by) {
      $('#commercial .datepicker').data("DateTimePicker").date(available_by);
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

    // $('#commercial .btn-print-list').click( function(event) {
    //   // show spinner
    //   $(this).toggleClass('active');
    //   timer2 = setTimeout(clearSpinner, 15000);
    // });

    $('#commercial input').keydown(CommercialUnits.preventEnter);
    $('#commercial #address').bind('railsAutocomplete.select', CommercialUnits.throttledSearch);
    $('#commercial #address').change(CommercialUnits.throttledSearch);
    $('#commercial #rent_min').change(CommercialUnits.throttledSearch);
    $('#commercial #sq_footage_min').change(CommercialUnits.throttledSearch);
    $('#commercial #sq_footage_max').change(CommercialUnits.throttledSearch);
    $('#commercial #rent_max').change(CommercialUnits.throttledSearch);
    $('#commercial #landlord').bind('railsAutocomplete.select', CommercialUnits.throttledSearch);
    $('#commercial #landlord').change(CommercialUnits.throttledSearch);
    $('#commercial #status').change(CommercialUnits.throttledSearch);
    $('#commercial #neighborhood_ids').change(CommercialUnits.throttledSearch);
    $('#commercial #commercial_property_type_id').change(CommercialUnits.throttledSearch);
    $('#commercial #listing_id').change(CommercialUnits.throttledSearch);

    // index page - selecting listings menu dropdown
    $('#commercial #emailListings').click(Listings.sendMessage);
    $('#commercial tbody').on('click', 'i', Listings.toggleListingSelection);
    $('#commercial .select-all-listings').click(Listings.selectAllListings);
    $('#commercial .selected-listings-menu').on('click', 'a', function() {
      var action = $(this).data('action');
      if (action in Listings.indexMenuActions) Listings.indexMenuActions[action]();
    });

    // for drag n dropping photos/documents
    // disable auto discover
    Dropzone.autoDiscover = false;
    CommercialUnits.initializeImageDropzone();
    CommercialUnits.initializeDocumentsDropzone();

    CommercialUnits.passiveRealTimeUpdate();
  };

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    Listings.hideSpinner();
  }
});

$(document).ready(CommercialUnits.initialize);