UserWaterfalls = {};

(function() {

	// if the user has selected enough information, we can determine what 
	// the waterfall rate will be
	UserWaterfalls.getRate = function() {
		var search_path = $('#waterfall #get-rates-url').data('path');

		var parent_id = $('#waterfall #user_waterfall_parent_agent_id').val();
		var level_id = $('#waterfall #user_waterfall_level').val();

		if (parent_id && level_id) {
		  $.ajax({
		    url: search_path,
		    data: {
		    	parent_agent_id: parent_id,
		    	level: level_id
		    }
		  });
		}
	};

	UserWaterfalls.initialize = function() {
		$('#waterfall #user_waterfall_parent_agent_id').change(UserWaterfalls.getRate);
		$('#waterfall #user_waterfall_level').change(UserWaterfalls.getRate);
	};

})();

$(document).ready(UserWaterfalls.initialize);