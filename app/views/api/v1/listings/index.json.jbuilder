json.prettify! if %w(1 yes true).include?(params["pretty"])

json.total_items @listings.total_count
json.total_pages @listings.total_pages
json.page @listings.current_page

json.items do
	json.partial! 'api/v1/units/unit', collection: @listings, as: :listing
end