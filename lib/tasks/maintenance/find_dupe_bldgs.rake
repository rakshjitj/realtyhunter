namespace :maintenance do
	desc "print list of buildings that were duplicated"
	task find_dupe_bldgs: :environment do
		log = ActiveSupport::Logger.new('log/find_dupe_bldgs.log')
		start_time = Time.now

		results = []
		Building.all.each do |b|
			records = Building.where(street_number: b.street_number)
				.where("route ilike ?", "%#{b.route}%")
			if (records.length > 1)
				records.each do |r|
					if !results.include?(r)
						results << r
					end
				end
			end
		end

		results.each do |r|
			puts "#{r.street_number} #{r.route} - Building ID: #{r.id}"
		end

	end
end
