class GenerateResidentialCSV
	@queue = :generate_csv

	# takes in residential listings
	def self.perform(user_id)
    UnitMailer.send_residential_csv(user_id).deliver
  end

end