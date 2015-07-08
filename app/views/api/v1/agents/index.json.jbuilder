json.prettify! if %w(1 yes true).include?(params["pretty"])

json.total_items @agents.total_count
json.total_pages @agents.total_pages
json.page @agents.current_page

json.items do
	json.array!(@agents) do |agent|
		json.partial! agent, agent:agent
	end
end