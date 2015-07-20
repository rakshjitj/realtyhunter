class AddUnitDescriptionToResidentialUnits < ActiveRecord::Migration
  def change
    add_column :residential_units, :description, :string
  end
end
