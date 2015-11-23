Careers = {};

(function() {
	// any phone #'s listed in 'access info' on main index pg should
  // be automatically detected
	Careers.detectPhoneNumbers = function () {
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {

			var countrycodes = "1"
			var delimiters = "-|\\.|—|–|&nbsp;"
			var phonedef = "\\+?(?:(?:(?:" + countrycodes + ")(?:\\s|" + delimiters + ")?)?\\(?[2-9]\\d{2}\\)?(?:\\s|" + delimiters + ")?[2-9]\\d{2}(?:" + delimiters + ")?[0-9a-z]{4})"
			var spechars = new RegExp("([- \(\)\.:]|\\s|" + delimiters + ")","gi") //Special characters to be removed from the link
			var phonereg = new RegExp("((^|[^0-9])(href=[\"']tel:)?((?:" + phonedef + ")[\"'][^>]*?>)?(" + phonedef + ")($|[^0-9]))","gi")

			function ReplacePhoneNumbers(oldhtml) {
				//Created by Jon Meck at LunaMetrics.com - Version 1.0
				var newhtml = oldhtml.replace(/href=['"]callto:/gi,'href="tel:')
				newhtml = newhtml.replace(phonereg, function ($0, $1, $2, $3, $4, $5, $6) {
				    if ($3) return $1;
				    else if ($4) return $2+$4+$5+$6;
				    else return $2+"<a href='tel:"+$5.replace(spechars,"")+"'>"+$5+"</a>"+$6; });
				return newhtml;
			}

			$('.phone').map(function() {
				$(this).html(ReplacePhoneNumbers($(this).html()))
			});
		}
	};

	Careers.setupSortableColumns = function() {
		$('#careers .th-sortable').click(function(e) {
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
			Careers.doSearch(sort_by_col, sort_direction);
		});
	};

	// for searching on the index page
	Careers.doSearch = function (sort_by_col, sort_direction) {
		var search_path = $('#careers-search-filters').attr('data-search-path');

	  Forms.showSpinner();

	  $.ajax({
	    url: search_path,
	    data: {
        name: $('#careers #name').val(),
        submitted_date: $('#careers #submitted_date').val(),
        status: $('#careers #status').val(),
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

	// search as user types
	Careers.timer;

	Careers.clearTimer = function() {
		clearTimeout(Careers.timer);
	};

	Careers.throttledSearch = function () {
		//clear any interval on key up
		if (Careers.timer) {
		  clearTimeout(Careers.timer);
		}
	  Careers.timer = setTimeout(Careers.doSearch, 500);
	};

	Careers.initialize = function() {

		document.addEventListener("page:restore", function() {
		  Forms.hideSpinner();
		});
		Forms.hideSpinner();

		// main index table
		Careers.setupSortableColumns();

		$('.close').click(function() {
			Forms.hideSpinner();
		});

		// index filtering
		$('#careers input').keydown(Forms.preventEnter);
		$('#careers #name').bind('railsAutocomplete.select', Careers.throttledSearch);
		$('#careers #name').change(Careers.throttledSearch);
	  $('#careers #status').change(Careers.throttledSearch);
	  $('#careers #submitted_date').blur(Careers.throttledSearch);

		// index page - selecting listings menu dropdown
		$('#careers #emailListings').click(Forms.sendMessage);
		$('#careers #deleteMultiple').click(Forms.deleteMultiple);

		$('#careers tbody').on('click', 'i', Forms.toggleListingSelection);
		$('#careers .select-all-listings').click(Forms.selectAllListings);
		$('#careers .selected-listings-menu').on('click', 'a', function() {
			var action = $(this).data('action');
			if (action in Forms.indexMenuActions) Forms.indexMenuActions[action]();
		});

		Careers.detectPhoneNumbers();
	};

})();

$(document).ready(Careers.initialize);