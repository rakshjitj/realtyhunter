// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
// these 2 must be first:
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require bootsy
//= require jquery.ui.all
//= require html.sortable.min
// mapbox
// leaflet.markercluster
//= require_tree .
//= require bootstrap-sprockets
//= require jquery.geocomplete.min
//= require autocomplete-rails
//= require dropzone
//= require local_time
//= require moment
//= require bootstrap-datetimepicker
//= require jquery.mousewheel.min
//= require selectize
//= require jquery.infinite-pages
//= require jquery.touchSwipe.min
//= require nested_form_fields
// must be last:
//= require turbolinks

$(document).ready(function() {
	// change all date input fields to auto-open the calendar
	$('.datepicker').each(function() {
    $(this).datetimepicker({
  	  viewMode: 'days',
  	  format: 'MM/DD/YYYY',
  	  allowInputToggle: true
  	});
  });
  $('.datepicker').each(function() {
    var date_value = $(this).attr('data-available-by');
    if (date_value) {
      $(this).data("DateTimePicker").date(date_value);
    }
  });

	$('input[type=number]').mousewheel(function(){
		event.preventDefault();
	});

	// submit login form on enter
	$('#session_password').keydown(function(e) {
	    if (e.keyCode == 13) {
	      $(this).closest('form').submit();
	    }
	});

	// .modal-backdrop classes
	$(".modal-transparent").on('show.bs.modal', function () {
	  setTimeout( function() {
	    $(".modal-backdrop").addClass("modal-backdrop-transparent");
	  }, 0);
	});
	$(".modal-transparent").on('hidden.bs.modal', function () {
	  $(".modal-backdrop").addClass("modal-backdrop-transparent");
	});

	$(".modal-fullscreen").on('show.bs.modal', function () {
	  setTimeout( function() {
	    $(".modal-backdrop").addClass("modal-backdrop-fullscreen");
	  }, 0);
	});
	$(".modal-fullscreen").on('hidden.bs.modal', function () {
	  $(".modal-backdrop").addClass("modal-backdrop-fullscreen");
	});

	Common.detectPhoneNumbers();

  // navbar
  var sideslider = $('[data-toggle=collapse-side]');
  var sel = sideslider.attr('data-target');
  var sel2 = sideslider.attr('data-target-2');
  sideslider.click(function(event){
    $(sel).toggleClass('in');
    $(sel2).toggleClass('out');
  });

  if (Common.onMobileDevice()) {
    $('.navbar-desktop').remove();
  } else {
    $('.navbar-mobile').remove();
  }

  $('#infinite-table-container').infinitePages({
      debug: false,
      loading: function() {
        // console.log("Loading...");
        return $(this).text("Loading...");
      },
      success: function() {
        // console.log('success!');
      },
      error: function() {
        // console.log("Trouble! Please drink some coconut water and click again");
        return $(this).text("Trouble! Please drink some coconut water and click again");
      }
    });

});

// debugging
$(window).unload(function() {
	Deals.clearTimer();
	Careers.clearTimer();
	ContactUs.clearTimer();
	Partner.clearTimer();
	Announcements.clearTimer();
  ResidentialListings.clearAnnouncementsTimer();
  ResidentialListings.clearTimer();
  CommercialListings.clearTimer();
  SalesListings.clearTimer();
});
