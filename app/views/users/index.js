// Append new data
$("<%=j render @users, :manager => nil %>")
  .appendTo($(".infinite-table"));
Listings.hideSpinner();

// Update pagination link
<% if @users.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@users, 'Load More', remote: true) %>");
<% end %>
