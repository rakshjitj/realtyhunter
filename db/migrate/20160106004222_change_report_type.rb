class ChangeReportType < ActiveRecord::Migration
  def change
  	remove_column :roomsharing_applications, :report_url, :date
  	add_column  :roomsharing_applications, :report_url, :string
  end
end
