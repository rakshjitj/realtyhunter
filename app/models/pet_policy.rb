class PetPolicy < ActiveRecord::Base
	belongs_to :company
	has_many :landlords

	def self.policies_that_allow_cats(company_id, takes_cats)
		dogs_only = PetPolicy.where(name: "Dogs only", company_id: company_id).first;
		no_pets = PetPolicy.where(name: "No pets", company_id: company_id).first;
		
		if takes_cats
			policies = PetPolicy.where(company_id: company_id)
				.where.not(id: [dogs_only.id, no_pets.id])
		else
			policies = PetPolicy.where(id: [dogs_only.id, no_pets.id],
				company_id: company_id)
		end
		
		policies
	end

	def self.policies_that_allow_dogs(company_id, takes_dogs)
		cats_only = PetPolicy.where(name: "Cats only", company_id: company_id).first;
		no_pets = PetPolicy.where(name: "No pets", company_id: company_id).first;
		if takes_dogs
			policies = PetPolicy.where(company_id: company_id)
				.where.not(id: [cats_only.id, no_pets.id])
		else
			policies = PetPolicy.where(id: [cats_only.id, no_pets.id],
				company_id: company_id)
		end

		policies
	end

end
