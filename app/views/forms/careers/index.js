// Append new data
$("<%=j render partial: 'forms/careers/entry', collection: @entries, as: :entry %>")
  .appendTo($(".infinite-table"));
Forms.hideSpinner();

// Update pagination link
<% if @entries.last_page? %>
  $('.pagination-wrapper').remove();
<% else %>
  $('.pagination-wrapper').html("<%=j (render :partial => 'shared/pagination', locals: {:models => @entries}) %>");
<% end %>
