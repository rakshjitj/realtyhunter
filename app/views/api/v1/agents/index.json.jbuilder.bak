json.prettify! if %w(1 yes true).include?(params["pretty"])

json.total_items @agents.total_count
json.total_pages @agents.total_pages
json.page @agents.current_page

json.items do
	json.partial! 'api/v1/users/user', collection: @agents, as: :user
end