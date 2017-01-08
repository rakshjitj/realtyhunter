class AddIsExclusiveAgreementSignedToResidentialListing < ActiveRecord::Migration
  def change
    add_column :units, :is_exclusive_agreement_signed, :boolean, default: false
  end
end
