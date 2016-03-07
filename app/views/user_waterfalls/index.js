// Append new data
$("<%=j render partial: 'user_waterfalls/user_waterfall', collection: @entries, as: :entry %>")
  .appendTo($(".infinite-table"));
Buildings.hideSpinner();

// Update pagination link
<% if @entries.last_page? %>
  $('.pagination-wrapper').remove();
<% else %>
  $('.pagination-wrapper').html("<%=j (render :partial => 'shared/pagination', locals: {:models => @entries}) %>");
<% end %>
