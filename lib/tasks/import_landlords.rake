require 'csv'

task :import_landlords => :environment do
  company = Company.find_by(name: 'MyspaceNYC')

  #fees = []

	puts "Getting data for all landlords..."
	count = 0
	CSV.foreach('lib/tasks/landlords.csv', col_sep: ';') { |row| 
		
		if count == 0
			count = count + 1
			next
		end
		count = count + 1
		# csv columns are as follows:
		# "id";"name";"total_listings";"assigned_agent";"code";"owners_info";"listing_agent_percentage";"properties";"months_requiered";"pet_policy";"notes"
		# We don't use the assigned_agent, properties, months_required or pet policy here...

		name = row[1]
		code = row[4]
		# if no code is present, make the code the same as the name
		if !code || code.empty?
			code = name
		else
			# if code is present but name is blank
			if !name || name.empty?
				name = code
			end
		end

		#puts "\n\n"
		#p row 
		if row.length == 0
			puts "Malformed row, no data. Skipping."
			next
		end
		#puts "CODE #{row[4]} NAME #{row[1]}"
		#fees << row[6]

		found = Landlord.find_by(name: row[1])
		if !found
			landlord = Landlord.create!({
				name: name,
				code: code,
				management_info: row[5],
				notes: row[10],
				listing_agent_percentage: (!row[6] || !row[6].empty?) ? row[6].to_i : nil,
				company: company
			})
			puts "... adding #{landlord.code}"
		else
			puts "... #{row[4]} already exists. Skipping."
		end
	}

	#puts "#{fees.uniq}"
	puts "Done!"
end