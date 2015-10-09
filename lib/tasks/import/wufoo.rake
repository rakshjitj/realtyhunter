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
				db_column = field['Title'].gsub(/\s+/, '_').gsub(/\?/, '').gsub(/\//, '')
					.gsub(/-/, '_').gsub(/___/, '_').gsub(/__/, '_').downcase
				fields[field['ID']] = db_column
			end
			
			fields
		end

		# roommates-form
		def import_roommates_web_form(wufoo, company)
			form = wufoo.form('z15ov1by0w7n41d') 
			fields = build_fields(form)

			hash = {}
			entries = form.entries
			entries.each do |entry|
				name = ''
				entry.each do |entry_field, val|
					db_column = fields[entry_field]
					if !db_column.blank?
						if db_column == 'cats_allowed' || db_column == 'dogs_allowed'
							hash[db_column.to_sym] = val == 'Yes' ? true : false
						elsif db_column == 'name_first'
							name = val + name
						elsif db_column == 'name_last'
							name = name + ' ' + val
						elsif db_column == 'upload_picture_of_yourself'
							# take the url from between the parentheses
							open_par = val.index('(')
							close_par = val.index(')')
							if open_par && close_par
								hash[db_column.to_sym] = val.slice(open_par + 1, close_par - open_par - 1)
							end

						elsif db_column == 'what_neighborhood_do_you_want_to_live_in'
							hash[:neighborhood] = Neighborhood.find_by(name: val)

						elsif db_column == 'move_in_date'
							hash[db_column.to_sym] = Date.parse(val) #	Tuesday, October 6, 2015

						else
							hash[db_column.to_sym] = val
						end
					end
				end
				hash[:name] = name # full name

				hash[:created_at] = entry["DateCreated"]
				hash[:created_by] = entry["CreatedBy"]
				
				if !entry["DateUpdated"].blank?
					hash[:updated_at] = entry["DateUpdated"]
				end

				hash[:company_id] = company.id

				#puts hash.inspect
				query = {name: hash[:name],
					email: hash[:email],
					phone_number: hash[:phone_number],
					created_by: hash[:created_by],
					#created_at: hash[:created_at],
					company_id: hash[:company_id]}

				found = Roommate.where(query).first
				#puts "FOUND IS #{found.inspect} #{query.inspect} \n #{hash.inspect}"
				if !found
					#puts "CREATING"
					Roommate.create!(hash)
				end
				#puts wu.errors.inspect
			end
		end

		def import_contact_us_form(wufoo, company)
			form = wufoo.form('m13cggzo03ka4xv') 
			fields = build_fields(form)
			hash = {}
			entries = form.entries
			entries.each do |entry|
				name = ''
				entry.each do |entry_field, val|
					db_column = fields[entry_field]
					if !db_column.blank?
						if db_column == 'name_first'
							name = val + name
						elsif db_column == 'name_last'
							name = name + ' ' + val
						elsif db_column == 'min_price' || db_column == 'max_price'
							if !val.blank?
								hash[db_column.to_sym] = val.to_i
							end
						else
							hash[db_column.to_sym] = val
						end
					end
				end
				hash[:name] = name # full name

				hash[:company_id] = company.id

				query = {name: hash[:name],
					email: hash[:email],
					phone_number: hash[:phone_number],
					how_did_you_hear_about_us: hash[:how_did_you_hear_about_us],
					company_id: hash[:company_id]}

				found = WufooContactUsForm.where(query).first
				if !found
					WufooContactUsForm.create!(hash)
				end
			end
		end

		# partner-with-myspace-nyc
		def import_partner_form(wufoo, company)
			form = wufoo.form('rt5glur0xdke0a') 
			fields = build_fields(form)
			hash = {}
			entries = form.entries
			entries.each do |entry|

				name = ''
				entry.each do |entry_field, val|
					db_column = fields[entry_field]
					if !db_column.blank?
						if db_column == 'name_first'
							name = val + name
						elsif db_column == 'name_last'
							name = name + ' ' + val
						elsif db_column == 'renovated'
							hash[db_column.to_sym] = (val == 'Yes') ? true : false
						elsif db_column =~ /included/
							if !val.blank? # if blank, it was left as 'false'
								hash[db_column.to_sym] = true
							end
						else
							hash[db_column.to_sym] = val
						end
					end
				end
				hash[:name] = name # full name

				hash[:company_id] = company.id

				query = {name: hash[:name],
					email: hash[:email],
					phone_number: hash[:phone_number],
					how_did_you_hear_about_us: hash[:how_did_you_hear_about_us],
					company_id: hash[:company_id]}

				found = WufooPartnerWithUsForm.where(query).first
				if !found
					WufooPartnerWithUsForm.create!(hash)
				end
			end
		end

		###############################################################
		wufoo = WuParty.new(ENV['RH_WUFOO_ACCT'], ENV['RH_WUFOO_API'])
		#puts wufoo.forms
		company = Company.find_by(name:'MyspaceNYC')
		import_roommates_web_form(wufoo, company);
		import_contact_us_form(wufoo, company)
		import_partner_form(wufoo, company)
	end
end