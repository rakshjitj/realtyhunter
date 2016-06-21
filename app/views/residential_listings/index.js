// Append new data
if ($('#residential-desktop').length) {
  $("<%=j render partial: 'residential_listings/residential_listing', collection: @residential_units, locals: {res_images: @res_images, bldg_images: @bldg_images} %>")
    .appendTo($(".infinite-table-res"));
} else {
  $("<%=j render partial: 'residential_listings/mobile_list_view', collection: @residential_units, as: :residential_listing, locals: {res_images: @res_images, bldg_images: @bldg_images} %>")
    .appendTo($(".infinite-table"));
}
Listings.hideSpinner();

// Update pagination link
<% if @residential_units.last_page? %>
  $('.pagination-wrapper').remove();
<% else %>
  $('.pagination-wrapper').html("<%=j (render :partial => 'shared/pagination', locals: {:models => @residential_units}) %>");
<% end %>
