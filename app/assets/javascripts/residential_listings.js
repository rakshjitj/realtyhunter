ResidentialListings = {};

// TODO: break this up by controller action?

(function() {
  ResidentialListings.timer;
  ResidentialListings.announcementsTimer;
  ResidentialListings.selectedNeighborhoodIds = null;
  ResidentialListings.selectedUnitAmenityIds = null;
  ResidentialListings.selectedBuildingAmenityIds = null;

	// for searching on the index page
	ResidentialListings.doSearch = function (sortByCol, sortDirection) {
	  var search_path = $('#res-search-filters').attr('data-search-path');

	  Listings.showSpinner();

    if (!sortByCol) {
      sortByCol = Common.getSearchParam('sort_by');
    }
    if (!sortDirection) {
      sortDirection = Common.getSearchParam('direction');
    }

    var data = {
        address: $('#address').val(),
        rent_min: $('#rent_min').val(),
        rent_max: $('#rent_max').val(),
        bed_min: $('#bed_min').val(),
        bed_max: $('#bed_max').val(),
        bath_min: $('#bath_min').val(),
        bath_max: $('#bath_max').val(),
        landlord: $('#landlord').val(),
        pet_policy_shorthand: $('#pet_policy_shorthand').val(),
        available_starting: $('#available_starting').val(),
        available_before: $('#available_before').val(),
        status: $('#status').val(),
        has_fee: $('#has_fee').val(),
        neighborhood_ids: ResidentialListings.selectedNeighborhoodIds,
        unit_feature_ids: ResidentialListings.selectedUnitAmenityIds,
        building_feature_ids: ResidentialListings.selectedBuildingAmenityIds,
        roomsharing_filter: $('#roomsharing_filter').prop('checked'),
        unassigned_filter: $('#unassigned_filter').prop('checked'),
        primary_agent_id:  $('#primary_agent_id').val(),
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

		ResidentialListings.passiveRealTimeUpdate();
	};

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

  ResidentialListings.queryAnnouncements = function(limit) {
    $.ajax({
      url: '/residential_listings/update_announcements',
      data: {
        limit: limit ? limit : 4,
      }
    });
  }

	// update the announcements every 60 seconds
	ResidentialListings.updateAnnouncements = function() {
		//console.log('updateAnnouncements ', $('.residential').length);
		if ($('.announcement').length) {
			//console.log('updating ann');
			ResidentialListings.queryAnnouncements();

			ResidentialListings.announcementsTimer = setTimeout(ResidentialListings.updateAnnouncements, 60 * 1 * 1000);
		}
	};

	// if a user remains on this page for an extended amount of time,
	// refresh the page every so often. We want to make sure they are
	// always viewing the latest data.
	ResidentialListings.passiveRealTimeUpdate = function() {
		ResidentialListings.clearTimer();
		// update every few minutes
	  ResidentialListings.timer = setTimeout(ResidentialListings.doSearch, 60 * 10 * 1000);
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
    var slideshowContent = '';
    var contentString = '<strong>' + key + '</strong><br />';

    var firstImageAdded = false;
    var imgCount = 0;
	  for (var i=0; i<info['units'].length; i++) {

      unit = info['units'][i];

      if (unit.image) {
        slideshowContent += '<div class="image' + (!firstImageAdded ? ' active' : '') + '">' +
            '<a href="https://myspace-realty-monster.herokuapp.com/residential_listings/'+ unit.id +
            '"><img src="' + unit.image + '" /></a>' +
            '</div>';
        firstImageAdded = true;
        imgCount++;
      }

      var shouldHighlightRow = imgCount == 1 && info['units'].length > 1;
	    contentString += '<div class="contentRow' + (shouldHighlightRow ? ' active' : '') +'">'
        + '<a href="https://myspace-realty-monster.herokuapp.com/residential_listings/'
        + unit.id + '">#' + unit.building_unit + ' ' +
        + unit.beds + ' bd / '
	      + unit.baths + ' baths $' + unit.rent + '</a></div>';
	    if (i == 5) {
	      contentString += '<div class="contentRow"><a href="https://myspace-realty-monster.herokuapp.com/residential_listings?building_id='
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

	ResidentialListings.toggleFeeOptions = function(event) {
		var isChecked = $('.has-fee').prop('checked');
		if (isChecked) {
			$('.show-op').addClass('hide');
			$('.show-tp').removeClass('hide');
		} else {
			$('.show-op').removeClass('hide');
			$('.show-tp').addClass('hide');
		}
	};

	ResidentialListings.inheritFeeOptions = function() {
		bldg_id = $('#residential_listing_unit_building_id').val();

		$.ajax({
			type: 'GET',
			url: '/residential_listings/fee_options/',
			data: {
				building_id: bldg_id,
			}
		});
	};

	ResidentialListings.setPositions = function() {
	  // loop through and give each task a data-pos
	  // attribute that holds its position in the DOM
	  $('.img-thumbnail').each(function(i) {
	    $(this).attr("data-pos", i+1);
	  });
	};

  ResidentialListings.sortOnColumnClick = function() {
		$('.th-sortable').click(function(e) {
      Common.sortOnColumnClick($(this), ResidentialListings.doSearch);
		});
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
    //DropZoneHelper.updateRotateImgLinks('residential', 'residential_listings');

    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active');

    DropZoneHelper.setPositions('residential', 'images');
    DropZoneHelper.makeSortable('residential', 'images');

    // after the order changes
    $('.sortable').sortable().bind('sortupdate', function(e, ui) {
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
    DropZoneHelper.setPositions('residential', 'documents');
    DropZoneHelper.makeSortable('residential', 'documents');

    // after the order changes
    $('..documents.sortable').sortable().bind('sortupdate', function(e, ui) {
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

  ResidentialListings.initEditor = function() {
    $('.has-fee').click(ResidentialListings.toggleFeeOptions);
    ResidentialListings.toggleFeeOptions();
    // when creating a new listing, inherit TP/OP from building's landlord
    $('#residential_listing_unit_building_id').change(ResidentialListings.inheritFeeOptions);

    // make sure datepicker is formatted before setting initial date below
    // use in residential/edit, on photos tab
    $('.datepicker').datetimepicker({
      viewMode: 'days',
      format: 'MM/DD/YYYY',
      allowInputToggle: true
    });
    var available_by = $('.datepicker').attr('data-available-by');
    if (available_by) {
      $('.datepicker').data("DateTimePicker").date(available_by);
    }

    // for drag n dropping photos/docs
    // disable auto discover
    Dropzone.autoDiscover = false;
    ResidentialListings.initializeImageDropzone();
    ResidentialListings.initializeDocumentsDropzone();
  }

  ResidentialListings.enablePassiveUpdates = function() {
    if(!Common.onMobileDevice()) {
      ResidentialListings.passiveRealTimeUpdate();
      ResidentialListings.updateAnnouncements();
    }
  }

  // called on index & show pages
  ResidentialListings.initMobileIndex = function() {
    $('#residential-desktop').remove();
    $('#residential-mobile input').keydown(ResidentialListings.preventEnter);

    $('.js-show-mobile-filters').click(function(e) {
      ResidentialListings.showCard('mobile-filters', e);
    });

    $('.js-show-announcements').click(function() {
      ResidentialListings.showCard('announcements');
      ResidentialListings.queryAnnouncements(100);
    });

    $('.js-show-map').click(function(e) {
      ResidentialListings.showCard('main', e);
      RHMapbox.centerOnMe();
    });

    $('.js-show-list-view').click(function(e) {
      ResidentialListings.showCard('list-view', e);
    });

    $('.js-run-search').click(function(e) {
      ResidentialListings.showCard('main', e);
      ResidentialListings.throttledSearch();
    });

    $('.js-show-main').click(function(e) {
      ResidentialListings.showCard('main', e);
    });

    $('.js-reset-filters').click(function(e) {
      $('#address').val('');
      $('#rent_min').val('');
      $('#rent_max').val('');
      $('#bed_min').val('Any');
      $('#bed_max').val('Any');
      $('#bath_min').val('Any');
      $('#bath_max').val('Any');
      $('#status').val('Active');
      $('#pet_policy_shorthand').val('Any');
      $('#neighborhood-select-multiple')[0].selectize.clear();
      $('#unit-amenities-select-multiple')[0].selectize.clear();
      $('#building-amenities-select-multiple')[0].selectize.clear();
    })

    // only on index, not show page
    if ($('#r-big-map-mobile').length) {
      RHMapbox.initMapbox('r-big-map-mobile', ResidentialListings.buildContentString);
     RHMapbox.centerOnMe();
   }
  }

  // called on index & show pages
  ResidentialListings.initDesktopIndex = function() {
    $('#residential-mobile').remove();
    ResidentialListings.enablePassiveUpdates();

    // hide spinner on main index when first pulling up the page
    document.addEventListener("page:restore", function() {
      Listings.hideSpinner();
      ResidentialListings.enablePassiveUpdates();
    });
    Listings.hideSpinner();

    $('.residential-desktop a').click(function() {
      Listings.showSpinner();
    });

    // main index table
    ResidentialListings.sortOnColumnClick();
    Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="updated_at"]'), 'desc')
    }

    $('.residential-desktop  .close').click(function() {
      Listings.hideSpinner();
    });

    $('#neighborhood-select-multiple').change(ResidentialListings.throttledSearch);
    $('#unit-amenities-select-multiple').change(ResidentialListings.throttledSearch);
    $('#building-amenities-select-multiple').change(ResidentialListings.throttledSearch);

    // just above main listings table - selecting listings menu dropdown
    $('#emailListings').click(Listings.sendMessage);
    $('#assignListings').click(Listings.assignPrimaryAgent);
    $('#unassignListings').click(Listings.unassignPrimaryAgent);
    $('tbody').on('click', 'i', Listings.toggleListingSelection);
    $('.select-all-listings').click(Listings.selectAllListings);
    $('.selected-listings-menu').on('click', 'a', function() {
      var action = $(this).data('action');
      if (action in Listings.indexMenuActions) Listings.indexMenuActions[action]();
    });

    // activate tooltips
    $('[data-toggle="tooltip"]').tooltip();

    RHMapbox.initMapbox('r-big-map', ResidentialListings.buildContentString);
  }

  // called on index & show pages
  ResidentialListings.initIndex = function() {
    if (Common.onMobileDevice()) {
      ResidentialListings.initMobileIndex();
    } else {
      ResidentialListings.initDesktopIndex();
    }

    $('input').keydown(ResidentialListings.preventEnter);
    $('#address').bind('railsAutocomplete.select', ResidentialListings.throttledSearch);
    $('#address').change(ResidentialListings.throttledSearch);
    $('#rent_min').change(ResidentialListings.throttledSearch);
    $('#rent_max').change(ResidentialListings.throttledSearch);
    $('#bed_min').change(ResidentialListings.throttledSearch);
    $('#bed_max').change(ResidentialListings.throttledSearch);
    $('#bath_min').change(ResidentialListings.throttledSearch);
    $('#bath_max').change(ResidentialListings.throttledSearch);
    $('#landlord').bind('railsAutocomplete.select', ResidentialListings.throttledSearch);
    $('#landlord').change(ResidentialListings.throttledSearch);
    $('#available_starting').blur(ResidentialListings.throttledSearch);
    $('#available_before').blur(ResidentialListings.throttledSearch);
    $('#pet_policy_shorthand').change(ResidentialListings.throttledSearch);
    $('#status').change(ResidentialListings.throttledSearch);
    $('#has_fee').change(ResidentialListings.throttledSearch);
    $('#roomsharing_filter').change(ResidentialListings.throttledSearch);
    $('#unassigned_filter').change(ResidentialListings.throttledSearch);
    $('#primary_agent_id').change(ResidentialListings.throttledSearch);

    ResidentialListings.selectedNeighborhoodIds = getURLParameterByName('neighborhood_ids');
    if (ResidentialListings.selectedNeighborhoodIds) {
      ResidentialListings.selectedNeighborhoodIds =
          ResidentialListings.selectedNeighborhoodIds.split(',');
    }

    $('#neighborhood-select-multiple').selectize({
      plugins: ['remove_button'],
      hideSelected: true,
      maxItems: 100,
      items: ResidentialListings.selectedNeighborhoodIds,
      onChange: function(value) {
        ResidentialListings.selectedNeighborhoodIds = value;
      }
    });

    ResidentialListings.selectedUnitAmenityIds = getURLParameterByName('unit_feature_ids');
    if (ResidentialListings.selectedUnitAmenityIds) {
      ResidentialListings.selectedUnitAmenityIds =
          ResidentialListings.selectedUnitAmenityIds.split(',');
    }
    $('#unit-amenities-select-multiple').selectize({
      plugins: ['remove_button'],
      hideSelected: true,
      maxItems: 100,
      items: ResidentialListings.selectedUnitAmenityIds,
      onChange: function(value) {
        ResidentialListings.selectedUnitAmenityIds = value;
      }
    });

    ResidentialListings.selectedBuildingAmenityIds = getURLParameterByName('building_feature_ids');
    if (ResidentialListings.selectedBuildingAmenityIds) {
      ResidentialListings.selectedBuildingAmenityIds =
          ResidentialListings.selectedBuildingAmenityIds.split(',');
    }
    $('#building-amenities-select-multiple').selectize({
      plugins: ['remove_button'],
      hideSelected: true,
      maxItems: 100,
      items: ResidentialListings.selectedBuildingAmenityIds,
      onChange: function(value) {
        ResidentialListings.selectedBuildingAmenityIds = value;
      }
    });

  }

  ResidentialListings.initShow = function() {
    $('.carousel-indicators > li:first-child').addClass('active');
    $('.carousel-inner > .item:first-child').addClass('active');

    if(!Common.onMobileDevice()) {
      $('#footer-mobile-show').remove();
      $('.mobile-show-page-wrap').removeClass();
    }
  }

  ResidentialListings.showCard = function(cardName, e) {
    $('.card.main').removeClass('card-visible');
    $('.card.mobile-filters').removeClass('card-visible');
    $('.card.announcements').removeClass('card-visible');
    $('.card.list-view').removeClass('card-visible');
    $('.card.' + cardName).addClass('card-visible');

    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }
  };

})();

$(document).on('keyup',function(evt) {
  if (evt.keyCode == 27) {
  	Listings.hideSpinner();
  }
});

$(document).ready(function() {
  var editPage = $('.residential_listings.edit').length;
  var newPage = $('.residential_listings.new').length;
  var indexPage = $('.residential_listings.index').length;

  // new and edit pages both render the same form template, so init them using the same code
  if (editPage || newPage) {
    ResidentialListings.initEditor();
  } else if (indexPage) {
    ResidentialListings.initIndex();
  } else {
    ResidentialListings.initShow();
  }
});
