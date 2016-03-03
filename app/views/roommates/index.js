// Append new data
$("<%=j render partial: 'roommates/roommate', collection: @roommates %>")
  .appendTo($(".infinite-table"));
Roommates.hideSpinner();

// Update pagination link
<% if @roommates.last_page? %>
  $('.pagination-wrapper').remove();
<% else %>
  $('.pagination-wrapper').html("<%=j (render :partial => 'shared/pagination', locals: {:models => @roommates}) %>");
<% end %>
