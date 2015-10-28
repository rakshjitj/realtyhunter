Announcements = {};

(function() {
	Announcements.updateUnits = function() {
		//console.log($('#announcements #address').val());
		$.ajax({
      url: "/announcements/get_units",
      data: {
        address: $('#announcements #address').val()
      },
      dataType: "script",
    });
	};

	Announcements.initialize = function() {
		$('#announcements #address').bind('railsAutocomplete.select', Announcements.updateUnits);
	};

})();

$(document).ready(Announcements.initialize);