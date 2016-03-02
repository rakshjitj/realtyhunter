// Append new data
$("<%=j render partial: 'residential_listings/residential_listing', collection: @residential_units, locals: {res_images: @res_images} %>")
  .appendTo($(".infinite-table"));
Listings.hideSpinner();

// Update pagination link
<% if @residential_units.last_page? %>
  $('.pagination').html("That's all, folks!");
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@residential_units, 'Load More', remote: true) %>");
<% end %>
