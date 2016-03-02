// Append new data
$("<%=j render @landlords %>")
  .appendTo($(".infinite-table"));
Landlords.hideSpinner();

// Update pagination link
<% if @landlords.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@landlords, 'Load More', remote: true) %>");
<% end %>
