// Append new data
$("<%=j render partial: 'user_waterfalls/user_waterfall', collection: @entries, as: :entry %>")
  .appendTo($(".infinite-table"));
Buildings.hideSpinner();

// Update pagination link
<% if @entries.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@entries, 'Load More', remote: true) %>");
<% end %>
