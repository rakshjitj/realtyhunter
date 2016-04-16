// Append new data
$("<%=j render @users, :manager => nil %>")
  .appendTo($(".infinite-table-users"));
Listings.hideSpinner();

// Update pagination link
<% if @users.last_page? %>
  $('.pagination-wrapper').remove();
<% else %>
  $('.pagination-wrapper').html("<%=j (render :partial => 'shared/pagination', locals: {:models => @users}) %>");
<% end %>
