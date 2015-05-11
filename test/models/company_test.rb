require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  def setup
    @company = Company.new(
    	name: "Myspace", 
   )
  end

  test "should be valid" do
    assert @company.valid?
  end

  test "name should be present" do
    @company.name = "     "
    assert_not @company.valid?
  end

  test "name should be unique" do
    duplicate_company = @company.dup
    duplicate_company.name = @company.name.upcase
    @company.save
    assert_not duplicate_user.valid?
  end

end
