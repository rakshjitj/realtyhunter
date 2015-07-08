namespace :import do
	desc "import Zillow's old landlord data into our database from the local csv"
	task :landlords => :environment do

		require 'csv'
		log = ActiveSupport::Logger.new('log/import_landlords.log')
		start_time = Time.now

	  company = Company.find_by(name: 'MyspaceNYC')

		puts "Getting data for all landlords..."
		log.info "Getting data for all landlords..."
		count = 0
		CSV.foreach('lib/tasks/import/landlords.csv', col_sep: ';') { |row| 
			
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

			if row.length == 0
				puts "Malformed row, no data. Skipping."
				next
			end

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
				puts "#{code} - adding"
				log.info "#{code} - adding"
			else
				puts "#{row[4]} - already exists, skipping"
				log.info "#{row[4]} - already exists, skipping"
			end
		}

		puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
		log.close
	end
end