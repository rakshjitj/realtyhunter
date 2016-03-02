// Append new data
$("<%=j render partial: 'roommates/roommate', collection: @roommates %>")
  .appendTo($(".infinite-table"));
Roommates.hideSpinner();

// Update pagination link
<% if @roommates.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@roommates, 'Load More', remote: true) %>");
<% end %>
