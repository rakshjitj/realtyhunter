// Append new data
$("<%=j render @buildings %>")
  .appendTo($(".infinite-table"));
Buildings.hideSpinner();

// Update pagination link
<% if @buildings.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@buildings, 'Load More', remote: true) %>");
<% end %>
