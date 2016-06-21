// Append new data
$("<%=j render partial: 'residential_listings/residential_listing', collection: @residential_units, locals: {res_images: @res_images, bldg_images: @res_bldg_images} %>")
  .appendTo($(".infinite-table-res"));
$("<%=j render partial: 'commercial_listings/commercial_listing', collection: @commercial_units, locals: {com_images: @com_images, bldg_images: @com_bldg_images} %>")
  .appendTo($(".infinite-table-com"));
Listings.hideSpinner();

// Update pagination link
<% if @residential_units.last_page? %>
  $('.res .pagination').remove();
<% else %>
  $('.res .pagination')
    .html("<%=j link_to_next_page(@residential_units, 'Load More', remote: true) %>");
<% end %>

<% if @commercial_units.last_page? %>
  $('.com .pagination').remove();
<% else %>
  $('.com .pagination')
    .html("<%=j link_to_next_page(@commercial_units, 'Load More', remote: true) %>");
<% end %>
