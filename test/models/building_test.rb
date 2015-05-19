require 'test_helper'

class BuildingTest < ActiveSupport::TestCase
  def setup
    @bldg = buildings(:one)
  end

  test "should be valid" do
    assert @bldg.valid?
  end

  test "street address should be present" do
    @bldg.street_address = "     "
    assert_not @bldg.valid?
  end

  test "street address should not be too long" do
    @bldg.street_address = "a" * 101
    assert_not @bldg.valid?
  end

  test "zip should be present" do
    @bldg.zip = "     "
    assert_not @bldg.valid?
  end

  test "zip should not be too long" do
    @bldg.zip = "a" * 11
    assert_not @bldg.valid?
  end

  test "street addresses should be unique" do
    duplicate_bldg = @bldg.dup
    duplicate_bldg.street_address = @bldg.street_address.upcase
    @bldg.save
    assert_not duplicate_bldg.valid?
  end

end
