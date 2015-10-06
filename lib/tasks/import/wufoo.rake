namespace :import do
	desc "import Wufoo's data into our database"
	task :wufoo => :environment do
		require 'wuparty'

		def build_fields(form)
			flattened_fields =  form.flattened_fields
			#puts flattened_fields.inspect
			fields = {}
			flattened_fields.each do |field|
				field['Title'].strip!
				db_column = field['Title'].gsub(/\s+/, '_').gsub(/\?/, '').gsub(/-/, '_').gsub(/___/, '_').downcase
				fields[field['ID']] = db_column
			end
			
			fields
		end

		def import_roommates_web_form(wufoo, company)
			# roommates-web-form
			form = wufoo.form('z15ov1by0w7n41d') 
			fields = build_fields(form)

			hash = {}
			entries = form.entries
			entries.each do |entry|
				entry.each do |entry_field, val|
					db_column = fields[entry_field]
					if !db_column.blank?
						if db_column == 'cats_allowed' || db_column == 'dogs_allowed'
							hash[db_column] = val == 'Yes' ? true : false
						elsif db_column == 'what_neighborhood_do_you_want_to_live_in'
							hash['neighborhood'] = Neighborhood.find_by(name: val)
						elsif db_column == 'move_in_date'
							hash[db_column] = Date.parse(val) #	Tuesday, October 6, 2015
						else
							hash[db_column] = val
						end
					end
				end

				hash[:created_at] = entry["DateCreated"]
				hash[:created_by] = entry["CreatedBy"]
				
				if !entry["DateUpdated"].blank?
					hash[:updated_at] = entry["DateUpdated"]
				end

				hash[:company_id] = company.id

				#puts hash.inspect
				Roommate.find_or_create_by!(hash)
				#puts wu.errors.inspect
			end
		end

		###############################################################
		wufoo = WuParty.new(ENV['RH_WUFOO_ACCT'], ENV['RH_WUFOO_API'])
		#puts wufoo.forms
		company = Company.find_by(name:'MyspaceNYC')
		import_roommates_web_form(wufoo, company);

	end
end