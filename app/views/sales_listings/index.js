// Append new data
$("<%=j render partial: 'sales_listings/sales_listing', collection: @sales_units, locals: {res_images: @res_images} %>")
  .appendTo($(".infinite-table"));
Listings.hideSpinner();

// Update pagination link
<% if @sales_units.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@sales_units, 'Load More', remote: true) %>");
<% end %>
