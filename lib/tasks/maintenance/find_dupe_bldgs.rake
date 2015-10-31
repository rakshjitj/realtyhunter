namespace :maintenance do
	desc "print list of buildings that were duplicated"
	task find_dupe_bldgs: :environment do
		log = ActiveSupport::Logger.new('log/find_dupe_bldgs.log')
		start_time = Time.now

		Building.all.each do |b|
			records = Building.where(route: b.route, street_number: b.street_number)
			if (records.length > 1)
				puts "ID: #{b.id} #{b.street_number} #{b.route}"
			end
		end

	end
end