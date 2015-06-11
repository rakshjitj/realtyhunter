json.prettify! if %w(1 yes true).include?(params["pretty"])

json.total_items @neighborhoods.count
json.total_pages @neighborhoods.total_pages
json.page @neighborhoods.current_page

json.items do
	json.array!(@neighborhoods) do |neighborhood|
		json.partial! neighborhood, neighborhood:neighborhood
	end
end