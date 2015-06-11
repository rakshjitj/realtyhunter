json.prettify! if %w(1 yes true).include?(params["pretty"])

json.total_items @listings.total_entries
json.total_pages @listings.total_pages
json.page @listings.current_page

json.items do
	json.array!(@listings) do |listing|
		json.partial! listing, listing:listing
	end
end