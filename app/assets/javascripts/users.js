Users = {};

(function() {

  Users.filterListings = function(event) {
    var search_path = $('#listings').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        status_listings: $('#users #status_listings').val(),
      },
      dataType: "script",
      success: function(data) {
        Landlords.hideSpinner();
      },
      error: function(data) {
        Landlords.hideSpinner();
      }
    });
  };

  Users.doSearch = function (event) {
    var search_path = $('#user-search-filters').attr('data-search-path');
    $.ajax({
      url: search_path,
      data: {
        name_email: $('#users #name_email').val(),
        status: $('#users #status').val(),
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

    $('#users input').keydown(Users.preventEnter);
    $('#users #name_email').bind('railsAutocomplete.select', Users.throttledSearch);
    $('#users #name_email').change(Users.throttledSearch);
    $('#users #status').change(Users.throttledSearch);
    $('#users #status_listings').change(Users.filterListings);

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
    if (agent_title_name == user_title_name) {
      $('.agent-type').show();
    } else {
      $('.agent-type').hide();
    }

    // TODO: this shit isn't working
    // don't let users click the 'upload photo' button unless a value has been set
    // var uploaded_file_name = $('#user_file');
    // uploaded_file_name.change(function() {
    //   if (uploaded_file_name.val().length > 0) {
    //     $('#btn-submit-img').prop('disabled', false);
    //   } else {
    //     $('#btn-submit-img').prop('disabled', true);
    //   }
    // });
  };

  Users.ready = function() {
    if ($('.users').length ||
        $('.companies.employees').length ||
        $('.companies.managers').length ||
        $('.offices.agents').length) {
      Users.initialize();
    }
  };
})();

$(document).on('ready page:load', Users.ready);

$(document).on('page:restore', Users.ready);
