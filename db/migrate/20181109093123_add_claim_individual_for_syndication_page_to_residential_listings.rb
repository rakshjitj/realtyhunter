class AddClaimIndividualForSyndicationPageToResidentialListings < ActiveRecord::Migration[5.0]
  def change
  	add_column :residential_listings, :claim_for_individual_syndication_page, :text, array:true, default: []
  end
end
