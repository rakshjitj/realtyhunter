class AddLockToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :lock_version, :integer, default: 0, null: false
  end
end
