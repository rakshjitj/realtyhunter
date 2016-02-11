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

	// residential commission amount
	if($('#residential_listing_cyof_true').is(":checked")){		
		$("#residential_listing_commission_amount").val('0');
		$("#residential_listing_commission_amount").attr("readonly", "readonly"); 
	}
	$('input[name="residential_listing[cyof]"]').change(function(){		
		if($(this).attr("id")=="residential_listing_cyof_true"){			
			$("#residential_listing_commission_amount").val('0');
			$("#residential_listing_commission_amount").attr("readonly", "readonly");      
		}
		else
		{			
			$("#residential_listing_commission_amount").val('');
			$("#residential_listing_commission_amount").removeAttr("readonly");      
		}
	});

	// residential validation
	if($('#residential_listing_rlsny').is(":checked")){		
		$("#residential_listing_floor_number").attr("required", true);
		$("#residential_listing_total_room_count").attr("required", true);
		$("#residential_listing_condition").attr("required", true);
		$("#residential_listing_showing_instruction").attr("required", true);
		$("#residential_listing_commission_amount").attr("required", true);

		$('label[for="residential_listing_floor_number"]').addClass("required");
		$('label[for="residential_listing_total_room_count"]').addClass("required");
		$('label[for="residential_listing_condition"]').addClass("required");
		$('label[for="residential_listing_showing_instruction"]').addClass("required");
		$('label[for="residential_listing_commission_amount"]').addClass("required");
		$('label[for="residential_listing_cyof"]').addClass("required");
		$('label[for="residential_listing_share_with_brokers"]').addClass("required");  
	}
	$('input[name="residential_listing[rlsny]"]').change(function(){		
		if($(this).is(":checked")){			
			$("#residential_listing_floor_number").attr("required", true);			
			$("#residential_listing_total_room_count").attr("required", true);
			$("#residential_listing_condition").attr("required", true);
			$("#residential_listing_showing_instruction").attr("required", true);
			$("#residential_listing_commission_amount").attr("required", true);

			$('label[for="residential_listing_floor_number"]').addClass("required");
			$('label[for="residential_listing_total_room_count"]').addClass("required");
			$('label[for="residential_listing_condition"]').addClass("required");
			$('label[for="residential_listing_showing_instruction"]').addClass("required");
			$('label[for="residential_listing_commission_amount"]').addClass("required");
			$('label[for="residential_listing_cyof"]').addClass("required");
			$('label[for="residential_listing_share_with_brokers"]').addClass("required");      
		}
		else
		{			
			$("#residential_listing_floor_number").removeAttr("required");
			$("#residential_listing_total_room_count").removeAttr("required");
			$("#residential_listing_condition").removeAttr("required");
			$("#residential_listing_showing_instruction").removeAttr("required");
			$("#residential_listing_commission_amount").removeAttr("required");

			$('label[for="residential_listing_floor_number"]').removeClass("required");
			$('label[for="residential_listing_total_room_count"]').removeClass("required");
			$('label[for="residential_listing_condition"]').removeClass("required");
			$('label[for="residential_listing_showing_instruction"]').removeClass("required");
			$('label[for="residential_listing_commission_amount"]').removeClass("required");
			$('label[for="residential_listing_cyof"]').removeClass("required");
			$('label[for="residential_listing_share_with_brokers"]').removeClass("required");  			
		}
	});

});

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

