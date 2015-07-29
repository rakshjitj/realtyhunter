Users = {};

(function() {

	Users.doSearch = function (event) {
		var search_path = $('#user-search-filters').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        search_params: {
          name_email: $('#name_email').val()
        } 
      },
      dataType: "script"
    });
  };

	// search as user types
  Users.timer;
  Users.throttledSearch = function() {
    clearInterval(Users.timer);  //clear any interval on key up
    Users.timer = setTimeout(Users.doSearch, 500);
  };
  
  // change enter key to tab
  Users.preventEnter = function (event) {
    if (event.keyCode == 13) {
      return false;
    }
  };

  Users.title_onchange_handler = function(event) {
  	input = $(this).find('option:selected').text();
  	var agent_title_name = $('#user_employee_title_id').attr('data-agent-title-name');
    if (input.toLowerCase() === agent_title_name) {
      $('.agent-type').show();
    } else {
      $('.agent-type').hide();
    }
  };  
	
	Users.initialize = function() {
		$('.auth-token-toggle').click(function (event) {
	    $('.auth-token').toggleClass('hidden');
	    event.preventDefault();
	  });

    $('input').keydown(Users.preventEnter); 
    $('#name_email').change(Users.throttledSearch);

    // $('#companies_select').change(function() {
    //   $.ajax({
    //     url: "<%= update_offices_users_path %>",
    //     data: {
    //       company_id : $('#companies_select').val()
    //     },
    //     dataType: "script"
    //   });
    // });

    $('#user_employee_title_id').change(Users.title_onchange_handler);
    $('.agent-type').hide();
    // if the user is currently an agent, display the select input with suboptions
  	var agent_title_name = $('#user_employee_title_id').attr('data-agent-title-name');
  	var user_title_name = $('#user_employee_title_id').attr('data-user-title-name');
  	console.log(agent_title_name, user_title_name);
  	if (agent_title_name == user_title_name) {
      $('.agent-type').show();
    } else {
      $('.agent-type').hide();
    }
	};
})();

$(document).ready(Users.initialize);