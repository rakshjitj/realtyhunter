class AddTenantSourcedToImages < ActiveRecord::Migration[5.0]
  def change
  	add_column :images, :tenant_sourced, :boolean, default: :false
  end
end
