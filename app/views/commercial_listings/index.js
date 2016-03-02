// Append new data
$("<%=j render partial: 'commercial_listings/commercial_listing', collection: @commercial_units, locals: {com_images: @com_images} %>")
  .appendTo($(".infinite-table-com"));
Listings.hideSpinner();

// Update pagination link
<% if @commercial_units.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@commercial_units, 'Load More', remote: true) %>");
<% end %>
