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

	// for searching on the index page
	UserWaterfalls.doSearch = function (sort_by_col, sort_direction) {
		//console.log(sort_by_col, sort_direction);
		var search_path = $('#waterfall-search-filters').attr('data-search-path');
	  Forms.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        parent_agent: $('#waterfall #parent_agent').val(),
        child_agent: $('#waterfall #child_agent').val(),
        level: $('#waterfall #level').val(),
        sort_by: sort_by_col,
        direction: sort_direction,
	    },
	    dataType: 'script',
	    success: function(data) {
	    	//console.log('SUCCESS:', data.responseText);
	    	Forms.hideSpinner();
			},
			error: function(data) {
				//console.log('ERROR:', data.responseText);
				Forms.hideSpinner();
			}
	  });
	};

	// search as user types
	UserWaterfalls.timer;

	UserWaterfalls.throttledSearch = function () {
		//console.log('throttling?');
		//clear any interval on key up
		if (UserWaterfalls.timer) {
			//console.log('yes, clearing');
		  clearTimeout(UserWaterfalls.timer);
		}
	  UserWaterfalls.timer = setTimeout(UserWaterfalls.doSearch, 500);
	};

	// change enter key to tab
	UserWaterfalls.preventEnter = function (event) {
	  if (event.keyCode == 13) {
	    //$('#checkbox_active').focus();
	    return false;
	  }
	};

	UserWaterfalls.clearNewEntry = function() {
		$('#waterfall #user_waterfall_parent_agent_id').val("");
		$('#waterfall #user_waterfall_child_agent_id').val("");
		$('#waterfall #user_waterfall_level').val("");
		$('#waterfall #user_waterfall_rate').val("");
	};

	UserWaterfalls.setupSortableColumns = function() {
		$('#waterfall .th-sortable').click(function(e) {
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
			UserWaterfalls.doSearch(sort_by_col, sort_direction);
		});
	};

	UserWaterfalls.initialize = function() {
		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		});
		Forms.hideSpinner();

		$('.close').click(function() {
			//console.log('detected click');
			Forms.hideSpinner();
		});

		// index filtering
		$('#waterfall input').keydown(UserWaterfalls.preventEnter);
		$('#waterfall #parent_agent').change(UserWaterfalls.throttledSearch);
		$('#waterfall #child_agent').change(UserWaterfalls.throttledSearch);
		$('#waterfall #parent_agent').bind('railsAutocomplete.select', UserWaterfalls.throttledSearch);
		$('#waterfall #child_agent').bind('railsAutocomplete.select', UserWaterfalls.throttledSearch);
		$('#waterfall #level').change(UserWaterfalls.throttledSearch);

		UserWaterfalls.setupSortableColumns();
		// adding a new entry
		$('#waterfall #user_waterfall_parent_agent_id').change(UserWaterfalls.getRate);
		$('#waterfall #user_waterfall_level').change(UserWaterfalls.getRate);
	};

})();

$(document).ready(UserWaterfalls.initialize);