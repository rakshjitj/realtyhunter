// Append new data
$("<%=j render @companies %>")
  .appendTo($(".infinite-table"));

// Update pagination link
<% if @companies.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@companies, 'Load More', remote: true) %>");
<% end %>
