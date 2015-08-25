CommercialUnits = {};

(function() {
  CommercialUnits.showSpinner = function() {
    $('#commercial .res-spinner-desktop').show();
  };

  CommercialUnits.hideSpinner = function() {
    $('#commercial .res-spinner-desktop').hide();
  };

  CommercialUnits.updatePropertySubTypes = function (ptype) {
    var url_path = $('#commercial_listing_property_type').attr('data-update-subtype-path');
    //console.log('got path ', url_path);
    $.ajax({
      url: "/commercial_listings/update_subtype", //url_path,
      data: {
          property_type: ptype
      },
      dataType: "script",
    });
  };

  CommercialUnits.doSearch = function(sort_by_col, sort_direction) {
    CommercialUnits.showSpinner();

    // sanitize invalid input before submitting
    if ($('#commercial #neighborhood_ids').val() == "{:id=>\"neighborhood_ids\"}") {
      $('#commercial #neighborhood_ids').val('');
    }

    var search_path = $('#com-search-filters').attr('data-search-path');
    //console.log(sort_by_col, sort_direction);
    $.ajax({
      url: search_path, 
      data: {
        address: $('#commercial #address').val(),
        rent_min: $('#commercial #rent_min').val(),
        rent_max: $('#commercial #rent_max').val(),
        landlord: $('#commercial #landlord').val(),
        status: $('#commercial #status').val(),
        property_type: $('#commercial #property_type').val(),
        listing_id: $('#commercial #listing_id').val(),
        neighborhood_ids: $('#commercial #neighborhood_ids').val(),
        sort_by: sort_by_col,
        direction: sort_direction,
      },
      dataType: "script",
      success: function(data) {
        CommercialUnits.hideSpinner();
      },
      error: function(data) {
        CommercialUnits.hideSpinner();
      }
    });
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
  CommercialUnits.throttledSearch = function () {
    // // only accept letter/number keys as search input
    // var charTyped = String.fromCharCode(e.which);
    // if (/[a-z\d]/i.test(charTyped)) {
    //     console.log("Letter or number typed: " + charTyped);
    // } else {
    //   return;
    // }
    
    clearTimeout(CommercialUnits.timer);  //clear any interval on key up
    timer = setTimeout(CommercialUnits.doSearch, 500);
  };
  
  // change enter key to tab
  CommercialUnits.preventEnter = function(event) {
    if (event.keyCode == 13) {
      //$('#checkbox_active').focus();
      return false;
    }
  };

  CommercialUnits.makeSortable = function() {
    // call sortable on our div with the sortable class
    $('#commercial .sortable').sortable({
      forcePlaceholderSize: true,
      placeholderClass: 'col col-xs-2 border border-maroon',
      dragImage: null
    });
  };

  CommercialUnits.removeImage = function (id, unit_id) {
    // make a DELETE ajax request to delete the file
    $.ajax({
      type: 'DELETE',
      url: '/commercial_listings/' + unit_id + '/unit_images/' + id,
      success: function(data){
        //console.log(data.message);
        $.getScript('/commercial_listings/' + unit_id + '/refresh_images')
      },
      error: function(data) {
        //console.log('ERROR:', data);
      }
    });
  };

  CommercialUnits.setPositions = function() {
    // loop through and give each task a data-pos
    // attribute that holds its position in the DOM
    $('#commercial .img-thumbnail').each(function(i) {
        $(this).attr("data-pos", i+1);
    });
  };

  CommercialUnits.updateRemoveImgLinks = function() {
    $('#commercial .delete-unit-img').click(function(event) {
      event.preventDefault();
      var id = $(this).attr('data-id');
      var unit_id = $(this).attr('data-unit-id');
      //console.log(id, unit_id);
      CommercialUnits.removeImage(id, unit_id);
    });
  };

  //call when typing or enter or focus leaving
  CommercialUnits.initialize = function () {

    document.addEventListener("page:restore", function() {
      CommercialUnits.hideSpinner();
    });
    CommercialUnits.hideSpinner();
    $('#commercial a').click(function() {
      CommercialUnits.showSpinner();
    });

    // main index table
    CommercialUnits.setupSortableColumns();

    $('#commercial_listing_property_type').change(function(e) {
      var optionSelected = $("option:selected", this);
      var textSelected   = optionSelected.text();
      console.log(textSelected);
      CommercialUnits.updatePropertySubTypes(textSelected);
    });
  	
    // make sure datepicker is formatted before setting initial date below
    $('.datepicker').datetimepicker({
      viewMode: 'days',
      format: 'MM/DD/YYYY',
      allowInputToggle: true
    });
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

    $('#commercial .btn-print-list').click( function(event) {
      // show spinner
      $(this).toggleClass('active');
      timer2 = setTimeout(clearSpinner, 15000);
    });

    $('#commercial input').keydown(CommercialUnits.preventEnter);
    $('#commercial #address').bind('railsAutocomplete.select', CommercialUnits.throttledSearch);
    $('#commercial #address').change(CommercialUnits.throttledSearch);
    $('#commercial #rent_min').change(CommercialUnits.throttledSearch);
    $('#commercial #rent_max').change(CommercialUnits.throttledSearch);
    $('#commercial #landlord').bind('railsAutocomplete.select', CommercialUnits.throttledSearch);
    $('#commercial #landlord').change(CommercialUnits.throttledSearch);
    $('#commercial #status').change(CommercialUnits.throttledSearch);
    $('#commercial #neighborhood_ids').change(CommercialUnits.throttledSearch);
    $('#commercial #property_type').change(CommercialUnits.throttledSearch);
    $('#commercial #listing_id').change(CommercialUnits.throttledSearch);

    // for drag n dropping photos

    // disable auto discover
    Dropzone.autoDiscover = false;
   
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
        $(file.previewTemplate).find('.dz-remove').attr('unit_id', response.unitID);
        // add the dz-success class (the green tick sign)
        $(file.previewElement).addClass("dz-success");
        $.getScript('/commercial_listings/' + response.unitID + '/refresh_images')
        file.previewElement.remove();
      },
      //when the remove button is clicked
      removedfile: function(file){
        // grap the id of the uploaded file we set earlier
        var id = $(file.previewTemplate).find('.dz-remove').attr('id'); 
        var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
        CommercialUnits.removeImage(id, unit_id);
        file.previewElement.remove();
      }
    });

    CommercialUnits.updateRemoveImgLinks();

    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active');

    CommercialUnits.setPositions();
    CommercialUnits.makeSortable();

    // after the order changes
    $('#commercial .sortable').sortable().bind('sortupdate', function(e, ui) {
        // array to store new order
        updated_order = []
        // set the updated positions
        CommercialUnits.setPositions();
        
        // populate the updated_order array with the new task positions
        $('.img-thumbnail').each(function(i){
          updated_order.push({ id: $(this).data('id'), position: i+1 });
        });
        console.log(updated_order);
        // send the updated order via ajax
        var cunit_id = $('#commercial').attr('data-cunit-id');
        $.ajax({
          type: "PUT",
          url: '/commercial_listings/' + cunit_id + '/unit_images/sort',
          data: { order: updated_order }
        });
    });
  };

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    CommercialUnits.hideSpinner();
  }
});

$(document).ready(CommercialUnits.initialize);