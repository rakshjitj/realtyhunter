// Append new data
if ($('.residential-desktop').length) {
  $("<%=j render partial: 'residential_listings/residential_listing', collection: @residential_units, locals: {res_images: @res_images} %>")
    .appendTo($(".infinite-table-res"));
} else {
  $("<%=j render partial: 'residential_listings/residential_listing_mobile_list_view', collection: @residential_units, as: :residential_listing, locals: {res_images: @res_images} %>")
    .appendTo($(".infinite-table"));
}
Listings.hideSpinner();

// Update pagination link
<% if @residential_units.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@residential_units, 'Load More', remote: true) %>");
<% end %>
