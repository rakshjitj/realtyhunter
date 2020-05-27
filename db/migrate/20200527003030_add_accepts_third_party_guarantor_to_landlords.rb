class AddAcceptsThirdPartyGuarantorToLandlords < ActiveRecord::Migration[5.0]
  def change
  	add_column :landlords, :accepts_third_party_gaurantor, :boolean, default: :false
  end
end
