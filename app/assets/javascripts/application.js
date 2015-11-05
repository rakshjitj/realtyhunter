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
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require bootsy
//= require jquery.ui.all
//= require html.sortable.min
//= require turbolinks
//= require_tree .
//= require bootstrap-sprockets
//= require jquery.geocomplete.min
//= require autocomplete-rails
//= require dropzone
//= require local_time
//= require moment
//= require bootstrap-datetimepicker
//= require jquery.mousewheel.min

$(document).ready(function() {
	// change all date input fields to auto-open the calendar
	$('.datepicker').datetimepicker({
	  viewMode: 'days',
	  format: 'MM/DD/YYYY',
	  allowInputToggle: true
	});

	$('input[type=number]').mousewheel(function(){
		event.preventDefault();
	});

	// submit login form on enter
	$('#session_password').keydown(function(e) {
		console.log('sdfdsds');
	    if (e.keyCode == 13) {
	      $(this).closest('form').submit();
	    }
	});
});

$(window).unload(function() {
	Careers.clearTimer();
	ContactUs.clearTimer();
	Partner.clearTimer();
	Announcements.clearTimer();
  ResidentialListings.clearAnnouncementsTimer();
  ResidentialListings.clearTimer();
  CommercialListings.clearTimer();
  SalesListings.clearTimer();
});

