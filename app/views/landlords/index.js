// Append new data
$("<%=j render @landlords %>")
  .appendTo($(".infinite-table"));
Landlords.hideSpinner();

// Update pagination link
<% if @landlords.last_page? %>
  $('.pagination-wrapper').remove();
<% else %>
  $('.pagination-wrapper').html("<%=j (render partial: 'shared/pagination', locals: {models: @landlords}) %>");
<% end %>
