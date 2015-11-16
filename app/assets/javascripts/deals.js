Deals = {};

(function() {
	Deals.setupSortableColumns = function() {
		$('#deals .th-sortable').click(function(e) {
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
			Deals.doSearch(sort_by_col, sort_direction);
		});
	};

	// for searching on the index page
	Deals.doSearch = function (sort_by_col, sort_direction) {
		var search_path = $('#deals-search-filters').attr('data-search-path');

	  Forms.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        //client_name: $('#deals #client_name').val(),
        address: $('#deals #address').val(),
        landlord_code: $('#deals #landlord_code').val(),
        closed_date_start: $('#deals #closed_date_start').val(),
        closed_date_end: $('#deals #closed_date_end').val(),
        sort_by: sort_by_col,
        direction: sort_direction,
	    },
	    dataType: 'script',
	    success: function(data) {
	    	Forms.hideSpinner();
			},
			error: function(data) {
				Forms.hideSpinner();
			}
	  });
	};

	Deals.timer;

	Deals.clearTimer = function() {
		clearTimeout(Deals.timer);
	};

	Deals.throttledSearch = function () {
		//clear any interval on key up
		if (Deals.timer) {
		  clearTimeout(Deals.timer);
		}
	  Deals.timer = setTimeout(Deals.doSearch, 500);
	};

	Deals.updateUnits = function() {
		$.ajax({
      url: "/deals/get_units",
      data: {
        building_id: $('#deals #deal_building_id').val()
      },
      dataType: "script",
    });
	};

	Deals.initialize = function(){
		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		});
		Forms.hideSpinner();

		// change all date input fields to auto-open the calendar
		$('.datepicker').datetimepicker({
		  viewMode: 'days',
		  format: 'MM/DD/YYYY',
		  allowInputToggle: true
		});
		$('#deals .datepicker').each(function(idx) {
			var available_by = $(this).attr('data-available-by');
			$(this).data("DateTimePicker").date(available_by);
		});

		// main index table
		Deals.setupSortableColumns();

		$('.close').click(function() {
			Forms.hideSpinner();
		});

		// index filtering
		$('#deals input').keydown(Forms.preventEnter);
		$('#deals #address').bind('railsAutocomplete.select', Deals.throttledSearch);
		$('#deals #address').change(Deals.throttledSearch);
		$('#deals #landlord_code').bind('railsAutocomplete.select', Deals.throttledSearch);
		$('#deals #landlord_code').change(Deals.throttledSearch);
		$('#deals #closed_date_start').blur(Deals.throttledSearch);
	  $('#deals #closed_date_end').blur(Deals.throttledSearch);

	  // edit
	  if ($('#deals #deal_building_id').length) {
		  $('#deals #deal_building_id').change(Deals.updateUnits);
		}

	};
})();

$(document).ready(Deals.initialize);