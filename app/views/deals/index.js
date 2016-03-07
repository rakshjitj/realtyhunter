// Append new data
$("<%=j render @deals %>")
  .appendTo($(".infinite-table"));
Forms.hideSpinner();

// Update pagination link
<% if @deals.last_page? %>
  $('.pagination-wrapper').remove();
<% else %>
  $('.pagination-wrapper').html("<%=j (render :partial => 'shared/pagination', locals: {:models => @deals}) %>");
<% end %>
