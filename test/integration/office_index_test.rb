require 'test_helper'

class OfficeIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @company = companies(:one)
    @office = offices(:one)
  end

  test "index only has offices for this one company" do
    log_in_as(@user)
    #get company_offices_path(@company), :company_id => @company.id
    #assert_template 'offices/index'
    #Office.each do |office|
    #  assert office.company, @company
    #end
  end

end