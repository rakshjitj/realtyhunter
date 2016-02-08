Buildings = {};

(function() {
  Buildings.showSpinner = function() {
    $('#buildings .index-spinner-desktop').show();
  };

  Buildings.hideSpinner = function() {
    $('#buildings .index-spinner-desktop').hide();
  };

  Buildings.filterListings = function(event) {
    var search_path = $('#listings').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        active_only: $('#buildings #listings_checkbox_active').prop('checked')
      },
      dataType: "script",
      success: function(data) {
        //console.log('SUCCESS:', data.responseText);
        Buildings.hideSpinner();
      },
      error: function(data) {
        //console.log('ERROR:', data.responseText);
        Buildings.hideSpinner();
      }
    });
  };

  Buildings.filterBuildings = function(sortByCol, sortDirection) {
  	var search_path = $('#search-filters').attr('data-search-path');

    Buildings.showSpinner();

    if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
        filter: $('#buildings #filter').val(),
        active_only: $('#buildings #checkbox_active').prop('checked'),
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
  };

  Buildings.sortOnColumnClick = function() {
    $('#buildings .th-sortable').click(function(e) {
      Common.sortOnColumnClick($(this), Buildings.filterBuildings);
    });
  };

  // search as user types
  Buildings.timer;
  Buildings.throttledBldgSearch = function() {
    clearTimeout(Buildings.timer);  //clear any interval on key up
    Buildings.timer = setTimeout(Buildings.filterBuildings, 500);
  };

  // change enter key to tab
  Buildings.preventEnter = function(event) {
    if (event.keyCode == 13) {
      $('#buildings #checkbox_active').focus();
      return false;
    }
  };

  Buildings.setPositions = function() {
    // loop through and give each task a data-pos
    // attribute that holds its position in the DOM
    $('#buildings .img-thumbnail').each(function(i) {
        $(this).attr("data-pos", i+1);
    });
  };

  Buildings.removeBldgImage = function (id, building_id) {
    // make a DELETE ajax request to delete the file
    $.ajax({
      type: 'DELETE',
      url: '/buildings/' + building_id + '/images/' + id,
      success: function(data){
        //console.log(data.message);
        $.getScript('/buildings/' + building_id + '/refresh_images')
      },
      error: function(data) {
        //console.log('ERROR:', data);
      }
    });
  };

  Buildings.makeSortable = function() {
    // call sortable on our div with the sortable class
    $('#buildings .sortable').sortable({
      forcePlaceholderSize: true,
      placeholderClass: 'col col-xs-2 border border-maroon',
      dragImage: null
    });
  };

  Buildings.updateRemoveImgLinks = function() {
    $('#buildings .delete-bldg-img').click(function(event) {
      event.preventDefault();
      var id = $(this).attr('data-id');
      var bldg_id = $(this).attr('data-bldg-id');
      console.log(id, bldg_id);
      Buildings.removeBldgImage(id, bldg_id);
    });
  };

  Buildings.initEditor = function() {
        // editing photos

    // disable auto discover
    Dropzone.autoDiscover = false;

    // grap our upload form by its id
    $("#building-dropzone").dropzone({
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
        $(file.previewTemplate).find('.dz-remove').attr('bldg_id', response.bldgID);
        // add the dz-success class (the green tick sign)
        $(file.previewElement).addClass("dz-success");
        $.getScript('/buildings/' + response.bldgID + '/refresh_images')
        file.previewElement.remove();
      },
      //when the remove button is clicked
      removedfile: function(file){
        // grap the id of the uploaded file we set earlier
        var id = $(file.previewTemplate).find('.dz-remove').attr('id');
        var bldg_id = $(file.previewTemplate).find('.dz-remove').attr('bldg_id');
        Buildings.removeBldgImage(id, bldg_id);
        file.previewElement.remove();
      }
    });

    Buildings.updateRemoveImgLinks();

    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active')

    Buildings.setPositions();
    Buildings.makeSortable();

    // after the order changes
    $('#buildings .sortable').sortable().bind('sortupdate', function(e, ui) {
      // array to store new order
      updated_order = []
      // set the updated positions
      Buildings.setPositions();

      // populate the updated_order array with the new task positions
      $('#buildings .img-thumbnail').each(function(i){
        updated_order.push({ id: $(this).data('id'), position: i+1 });
      });
      //console.log(updated_order);

      // send the updated order via ajax
      var bldg_id = $('#buildings').attr('data-bldg-id');
      $.ajax({
        type: "PUT",
        url: '/buildings/' + bldg_id + '/images/sort',
        data: { order: updated_order }
      });
    });

     var bldg_address = $('#map_canvas').attr('data-address') ? $('#map_canvas').attr('data-address') : 'New York, NY, USA';
    // google maps
    $("#bldg_panel").geocomplete({
      map: "#map_canvas",
      location: bldg_address,
      details: ".details"
    }).bind("geocode:result", function(event, result){
      //console.log(result);
    }).bind("geocode:error", function(event, result){
      //console.log("[ERROR]: " + result);
    });

    $(".autocomplete-input").geocomplete({
      map: "#map_canvas",
      location: bldg_address,
      details: ".details"
    }).bind("geocode:result", function(event, result){
      if (this.value == "New York, NY, USA") {
        this.value = '';
      }

      // update neighborhood options from google results
      var sublocality = '';
      for (var i =0; i<result["address_components"].length; i++) {
        if (result["address_components"][i]["types"][1] == "sublocality") {
          sublocality = result["address_components"][i]["short_name"];
        }
      }

      // if no neighborhood already set, update neighborhood from google results
      if ($('#neighborhood').val() == "") {
        $.ajax({
          type: "GET",
          url: '/buildings/neighborhood_options',
          data: {
            sublocality: sublocality,
          },
          success: function(data) {
            for (var i =0; i<result["address_components"].length; i++) {
              if (result["address_components"][i]["types"][0] == "neighborhood") {
                var nabe = result["address_components"][i]["short_name"];
                //console.log(nabe);
                $('#neighborhood').val(nabe);
              }
            }
          }
        });
      }

    }).bind("geocode:error", function(event, result){
      //console.log("[ERROR]: " + result);
    });
  }

  Buildings.initIndex = function() {
    document.addEventListener("page:restore", function() {
      Buildings.hideSpinner();
    });
    Buildings.hideSpinner();
    $('#buildings a').click(function() {
      Buildings.showSpinner();
    });

    // main index table
    Buildings.sortOnColumnClick();
    Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="formatted_street_address"]'), 'desc')
    }

    // search filters
    $('#buildings #filter').bind('railsAutocomplete.select', Buildings.throttledBldgSearch);
    $('#buildings #filter').keydown(Buildings.preventEnter);
    $('#buildings #filter').change(Buildings.throttledBldgSearch);
    // toggle between active and inactive units
    $('#buildings #checkbox_active').click(Buildings.throttledBldgSearch);
    $('#buildings #listings_checkbox_active').click(Buildings.filterListings);
  }

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
    Buildings.hideSpinner();
  }
});

$(document).ready(function () {
  var url = window.location.pathname;
  var buildings = url.indexOf('buildings') > -1;
  var editPage = url.indexOf('edit') > -1;
  var newPage = url.indexOf('new') > -1;
  if (buildings) {
    // new and edit pages both render the same form template, so init them using the same code
    if (editPage || newPage) {
      Buildings.initEditor();
    } else {
      Buildings.initIndex();
    }
  }
});
