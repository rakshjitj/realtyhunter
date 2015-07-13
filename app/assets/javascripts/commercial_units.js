CommercialUnits = {};

(function() {
  CommercialUnits.updatePropertySubTypes = function (ptype) {
    var url_path = $('#commercial_unit_property_type').attr('data-update-subtype-path');
    $.ajax({
      url: url_path,
      data: {
          property_type: ptype
      },
      dataType: "script",
    });
  };

  CommercialUnits.doSearch = function(event) {
    // sanitize invalid input before submitting
    if ($('#neighborhood_ids').val() == "{:id=>\"neighborhood_ids\"}") {
      $('#neighborhood_ids').val('');
    }

    var search_path = $('#com-search-filters').attr('data-search-path');
    $.ajax({
      url: search_path, //"<%= filter_commercial_units_path %>",
      data: {
        //search_params: {
          address: $('#address').val(),
          rent_min: $('#rent_min').val(),
          rent_max: $('#rent_max').val(),
          landlord: $('#landlord').val(),
          status: $('#status').val(),
          status: $('#property_type').val(),
          status: $('#listing_id').val(),
          neighborhood_ids: $('#neighborhood_ids').val(),
        //}
      },
      dataType: "script"
    });
  };

  // search as user types
  CommercialUnits.timer;
  CommercialUnits.throttledSearch = function () {
    clearTimeout(timer);  //clear any interval on key up
    timer = setTimeout(CommercialUnits.doSearch, 500);
  };
  
  // change enter key to tab
  CommercialUnits.preventEnter = function(event) {
    if (event.keyCode == 13) {
      //$('#checkbox_active').focus();
      return false;
    }
  };

  CommercialUnits.removeImage = function (id, unit_id) {
    // make a DELETE ajax request to delete the file
    $.ajax({
      type: 'DELETE',
      url: '/commercial_units/' + unit_id + '/unit_images/' + id,
      success: function(data){
        //console.log(data.message);
        $.getScript('/commercial_units/' + unit_id + '/refresh_images')
      },
      error: function(data) {
        //console.log('ERROR:', data);
      }
    });
  };

  //call when typing or enter or focus leaving
  CommercialUnits.initialize = function () {
    // change all date input fields to auto-open the calendar
    $('.datepicker').datetimepicker({
      viewMode: 'days',
      format: 'MM/DD/YYYY',
      allowInputToggle: true
    });

    $('#commercial_unit_property_type').change(function(e) {
      var optionSelected = $("option:selected", this);
      var textSelected   = optionSelected.text();
      CommercialUnits.updatePropertySubTypes(textSelected);
    });
  	
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

    $('.btn-print-list').click( function(event) {
      // show spinner
      $(this).toggleClass('active');
      timer2 = setTimeout(clearSpinner, 15000);
    });

    $('input').keydown(CommercialUnits.preventEnter);
    $('#address').keyup(CommercialUnits.throttledSearch);
    $('#rent_min').keyup(CommercialUnits.throttledSearch);
    $('#rent_max').keyup(CommercialUnits.throttledSearch);
    $('#landlord').keyup(CommercialUnits.throttledSearch);
    $('#status').change(CommercialUnits.throttledSearch);
    $('#neighborhood_ids').change(CommercialUnits.throttledSearch);
    $('#property_type').change(CommercialUnits.throttledSearch);
    $('#listing_id').keyup(CommercialUnits.throttledSearch);

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
        $.getScript('/commercial_units/' + response.unitID + '/refresh_images')
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

    $('.delete-unit-img').click(function(event) {
      event.preventDefault();
      var id = $(this).attr('data-id');
      var unit_id = $(this).attr('data-unit-id');
      //console.log(id, unit_id);
      CommercialUnits.removeImage(id, unit_id);
    });

    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active');

  };

})();

$(document).ready(CommercialUnits.initialize);