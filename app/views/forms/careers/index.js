// Append new data
$("<%=j render partial: 'forms/careers/entry', collection: @entries, as: :entry %>")
  .appendTo($(".infinite-table"));
Forms.hideSpinner();

// Update pagination link
<% if @entries.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@entries, 'Load More', remote: true) %>");
<% end %>
