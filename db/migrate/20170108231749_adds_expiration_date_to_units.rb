class AddsExpirationDateToUnits < ActiveRecord::Migration
  def change
    add_column :units, :exclusive_agreement_expires_at, :datetime
  end
end
