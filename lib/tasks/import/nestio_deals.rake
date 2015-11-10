namespace :import do
  desc "Import Nestio's past deals data into our database"
  task :nestio_deals => :environment do
  	require 'json'
  	log = ActiveSupport::Logger.new('log/import_nestio_deals.log')
		start_time = Time.now

		def create_deal(transaction, unit)
			closing_agents = transaction['closing_agents']
			transaction.delete('closing_agents')

			# NOTE: there's no valid client data in the nestio file anyway
			# if !transaction['client'].blank?
			# 	client_info = transaction['client']
			# 	puts client_info.inspect
			# 	#client_info.delete('client_referral')
			# 	#client_info.delete('client_referral_other')
			# 	#client_info.delete('people')
			# 	client = Client.create!(client_info['people'])
			# 	transaction.delete('client')
			# end

			deal = Deal.new(transaction)
			# if client
			# 	deal.client = client
			# end
			#if deal
				#puts unit.inspect
				deal.unit = unit
				if !unit
					puts "BLANK UNIT #{unit.inspect}"
				end

				if !closing_agents.blank? && closing_agents.length > 0
					closing_agents.each do |agent|
						user = User.find_by(email: agent['email'])
						if user
							deal.user = user
							#puts deal.user.inspect
						else
							#puts "USER NOT FOUND #{agent['email']}"
						end
					end
				end

				#begin
					deal.save!
				#rescue ActiveRecord::RecordInvalid => e
					#puts deal.errors.full_message
					#puts transaction
				#end
			#else
			#	puts transaction
			#end


			deal
		end

		def rebuild_missing_rh_data

		end

		# each line in the file represents 1 recorded transaction
		Deal.delete_all
		file = File.read('lib/tasks/import/myspace_nyc_transactions.json')

		idx = 1;
		file.each_line do |line|
			#begin
				data = JSON.parse!(line)
				transaction = data['transaction_info']
				unit_info = data['unit_info']
				if !unit_info
					#puts "[#{idx}] UNIT INFO BLANK"
					#puts data
					next
				end

				idx = idx + 1

				building_unit = unit_info['unit_number']	
				unit1 = Unit.where(listing_id: unit_info['id']).first
				unit2 = nil
				if building_unit
					unit2 = Unit.joins(:building)
						.where(building_unit: building_unit)
						.where("buildings.formatted_street_address ilike ?", "%#{unit_info['building']['street_address']}%")
						.first
				end

				if unit1 == unit2 && unit1 && unit2
					#puts "[MATCH] {data['unit_info']['id']} # #{building_unit}"
					deal = create_deal(transaction, unit1)
				elsif unit1
					#puts "[111111] #{data['unit_info']['id']} # #{building_unit}-- #{unit1.id}"
					deal = create_deal(transaction, unit1)
				elsif unit2
					#puts "[222222] #{data['unit_info']['id']} # #{building_unit} -- #{unit2.id}"
					deal = create_deal(transaction, unit2)
				elsif !unit1 && !unit2
					#puts "[NONE] #{unit_info['id']} # #{building_unit} -- NOT FOUND"
				end

				# if !deal
				# 	puts "NO DEAL"
				# 	puts transaction
				# 	exit
				# end

			# rescue JSON::ParserError => e
			# 	puts e.message
			# 	log.info e.message
			# end
		end
	
		#rescue Exception => e
			
    puts "Done!\n"
		log.info "Done!\n"
		end_time = Time.now
    duration = (start_time - end_time) / 1.minute
    log.info "Task finished at #{end_time} and last #{duration} minutes."
    log.close
	end
end

#UNIT INFO BLANK
#{"unit_info"=>nil, "transaction_info"=>{"closed_date"=>"2015/04/01", "lease_term"=>nil, "is_sale_deal"=>false, "closing_agents"=>[{"email"=>"yjohnson@myspacenyc.com", "id"=>4397, "name"=>"Yvan Johnson"}], "lease_start_date"=>nil, "lease_expiration_date"=>"2016/04/01", "id"=>10127, "commission"=>nil, "deal_notes"=>"", "client"=>{"client_referral"=>nil, "client_referral_other"=>"", "people"=>[{"first_name"=>"Mike ", "last_name"=>"Holmes", "id"=>16579, "date_of_birth"=>"1977-02-23", "phone_2"=>"", "email"=>"therealmikeholmes@gmail.com", "phone_1"=>"822-251-7508"}, {"first_name"=>"meredith  ", "last_name"=>"gran", "id"=>16580, "date_of_birth"=>"1984-11-10", "phone_2"=>"", "email"=>"punk4bird@gmail.com", "phone_1"=>"516-526-7934"}]}, "created_at"=>"2015/04/01 20:21:18", "listing_type"=>"For Rent", "price"=>nil, "move_in_date"=>nil}}
