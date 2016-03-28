class AddReportUrlToRentalApp < ActiveRecord::Migration
  def change
  	add_column  :roomsharing_applications, :report_url, :string
  end
end
