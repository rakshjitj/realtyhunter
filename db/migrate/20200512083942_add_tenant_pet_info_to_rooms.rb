class AddTenantPetInfoToRooms < ActiveRecord::Migration[5.0]
  def change
  	add_column :rooms, :tenant_pet_info, :string
  end
end
