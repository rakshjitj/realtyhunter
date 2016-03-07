//
// Used to manage the dropzone uploaders on the edit pages for:
// sales, residential, commercial, buildings
//
DropZoneHelper = {};
(function() {

  // sectionID is something like "#commercial" or "#residential"
  // It is marked near the top of the html file.

  // controllerPath is something like "commercial_listings" or "residential_listings"
  // It helps build the URL path we need to for calling ajax functions.

  // subsection is something like 'images' or 'documents'. It specifies what type of
  // data we're working with, so we don't accidentally update the wrong dropzone object
  DropZoneHelper.makeSortable = function(sectionID, subsection) {
    // call sortable on our div with the sortable class
    $('#' + sectionID + ' ' + '.' + subsection + '.sortable').sortable({
      forcePlaceholderSize: true,
      placeholderClass: 'col col-xs-2 border border-maroon',
      dragImage: null
    });
  };

  DropZoneHelper.currentlyDeleting = false;

  // make a DELETE ajax request to delete the file
  DropZoneHelper.removeImage = function (id, unit_id, controllerPath) {
    // if not currently in the middle of a deletion request, delete this photo
    if (!DropZoneHelper.currentlyDeleting) {
      DropZoneHelper.currentlyDeleting = true;
      Listings.showSpinner();
      $.ajax({
        type: 'DELETE',
        url: '/' + controllerPath + '/' + unit_id + '/unit_images/' + id,
        success: function(data){
          //console.log(data.message);
          $.getScript('/' + controllerPath + '/' + unit_id + '/refresh_images');
          Listings.hideSpinner();
          DropZoneHelper.currentlyDeleting = false;
        },
        error: function(data) {
          Listings.hideSpinner();
          DropZoneHelper.currentlyDeleting = false;
          //console.log('ERROR:', data);
        }
      });
    }
  };

  DropZoneHelper.rotateImage = function (id, unit_id, controllerPath) {
    Listings.showSpinner();
    // make a DELETE ajax request to delete the file
    $.ajax({
      type: 'PATCH',
      url: '/' + controllerPath + '/' + unit_id + '/unit_images/' + id + '/rotate',
      success: function(data){
        $.getScript('/' + controllerPath + '/' + unit_id + '/refresh_images');
        Listings.hideSpinner();
      },
      error: function(data) {
        Listings.hideSpinner();
        //console.log('ERROR:', data);
      }
    });
  };

  DropZoneHelper.removeDocument = function (id, unit_id, controllerPath) {
    // make a DELETE ajax request to delete the file
    //console.log(id, unit_id, controllerPath);
    $.ajax({
      type: 'DELETE',
      url: '/' + controllerPath + '/' + unit_id + '/documents/' + id,
      success: function(data){
        //console.log(data.message);
        $.getScript('/' + controllerPath + '/' + unit_id + '/refresh_documents')
      },
      error: function(data) {
        //console.log('ERROR:', data);
      }
    });
  };

  DropZoneHelper.setPositions = function(sectionID, subsection) {
    // loop through and give each task a data-pos
    // attribute that holds its position in the DOM
    if (subsection == 'images') {
      $('#' + sectionID + ' .img').each(function(i) {
        $(this).attr("data-pos", i);
      });
    } else if (subsection == 'documents') {
      $('#' + sectionID + ' .doc').each(function(i) {
        $(this).attr("data-pos", i);
      });
    }
  };

  DropZoneHelper.updateRemoveImgLinks = function(sectionID, controllerPath) {
    $('#' + sectionID + ' .delete-unit-img').click(function(event) {
      event.preventDefault();
      var id = $(this).attr('data-id');
      var unit_id = $(this).attr('data-unit-id');
      DropZoneHelper.removeImage(id, unit_id, controllerPath);
    });
  };

  DropZoneHelper.updateRotateImgLinks = function(sectionID, controllerPath) {
    $('#' + sectionID + ' .rotate-unit-img').click(function(event) {
      event.preventDefault();
      var id = $(this).attr('data-id');
      var unit_id = $(this).attr('data-unit-id');
      DropZoneHelper.rotateImage(id, unit_id, controllerPath);
    });
  };

  DropZoneHelper.updateRemoveDocLinks = function(sectionID, controllerPath) {
    $('#' + sectionID + ' .delete-unit-doc').click(function(event) {
      event.preventDefault();
      var id = $(this).attr('data-id');
      var unit_id = $(this).attr('data-unit-id');
      DropZoneHelper.removeDocument(id, unit_id, controllerPath);
    });
  };

})();
