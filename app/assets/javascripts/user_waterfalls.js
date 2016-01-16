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
		$('#waterfall #user_waterfall_agent_seniority_rate').val("");
		$('#waterfall #user_waterfall_child_agent_id').val("");
		$('#waterfall #user_waterfall_level').val("");
		$('#waterfall #user_waterfall_rate').val("");
	};

	UserWaterfalls.sortOnColumnClick = function() {
		$('#waterfall .th-sortable').click(function(e) {
			Common.sortOnColumnClick($(this), UserWaterfalls.doSearch);
		});
	};

	UserWaterfalls.initialize = function() {
		if (!$('#waterfall').length) {
			return;
		}

		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		});
		Forms.hideSpinner();

		$('.close').click(function() {
			Forms.hideSpinner();
		});

		// index filtering
		$('#waterfall input').keydown(UserWaterfalls.preventEnter);
		$('#waterfall #parent_agent').change(UserWaterfalls.throttledSearch);
		$('#waterfall #child_agent').change(UserWaterfalls.throttledSearch);
		$('#waterfall #parent_agent').bind('railsAutocomplete.select', UserWaterfalls.throttledSearch);
		$('#waterfall #child_agent').bind('railsAutocomplete.select', UserWaterfalls.throttledSearch);
		$('#waterfall #level').change(UserWaterfalls.throttledSearch);

		UserWaterfalls.sortOnColumnClick();
		Common.markSortingColumn();
    if (Common.getSearchParam('sort_by') === '') {
      Common.markSortingColumnByElem($('th[data-sort="parent_agent_name"]'), 'asc')
    }

		// adding a new entry
		$('#waterfall #user_waterfall_parent_agent_id').change(UserWaterfalls.getRate);
		$('#waterfall #user_waterfall_level').change(UserWaterfalls.getRate);
	};

})();

$(document).ready(UserWaterfalls.initialize);
