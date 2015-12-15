class AddInquireResponseFields < ActiveRecord::Migration
  def change
  	# map to response fields from TenantSafe inquries
  	add_column :roomsharing_applications, :referenceId, :string
  	add_column :roomsharing_applications, :orderId, :string
  	add_column :roomsharing_applications, :orderStatus, :string
  end
end
