json.prettify! if %w(1 yes true).include?(params["pretty"])

json.total_items @neighborhoods.total_count
json.total_pages @neighborhoods.total_pages
json.page @neighborhoods.current_page

json.items do
	json.partial! 'api/v1/neighborhoods/neighborhood', collection: @neighborhoods, as: :neighborhood
end