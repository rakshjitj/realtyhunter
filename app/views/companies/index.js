// Append new data
$("<%=j render @companies %>")
  .appendTo($(".infinite-table"));

// Update pagination link
<% if @companies.last_page? %>
  $('.pagination-wrapper').remove();
<% else %>
  $('.pagination-wrapper').html("<%=j (render :partial => 'shared/pagination', locals: {:models => @companies}) %>");
<% end %>
