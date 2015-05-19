require 'test_helper'

class ResidentialUnitTest < ActiveSupport::TestCase
  def setup
  	# fixtures not working, not sure why
    @unit = ResidentialUnit.new({
    	rent: 1,
    	building_unit: "sfddsfds",
    	beds: 1,
    	baths: 2
    	})
  end

  test "should be valid" do
    assert @unit.valid?
  end

  test "building_unit should be present" do
    @unit.building_unit = "     "
    assert_not @unit.valid?
  end

  test "rent should be present" do
    @unit.rent = "     "
    assert_not @unit.valid?
  end

	test "beds should be present" do
    @unit.beds = "     "
    assert_not @unit.valid?
  end

  test "baths should be present" do
    @unit.baths = "     "
    assert_not @unit.valid?
  end

  test "building_unit should not be too long" do
    @unit.building_unit = "a" * 51
    assert_not @unit.valid?
  end

  test "rent should not be too long" do
    @unit.rent = 1000000001
    assert_not @unit.valid?
  end

  test "beds should not be too long" do
    @unit.beds = 12
    assert_not @unit.valid?
  end

  test "baths should not be too long" do
    @unit.baths = 12
    assert_not @unit.valid?
  end

  test "building_unit should be unique" do
    duplicate_bldg = @unit.dup
    duplicate_bldg.building_unit = @unit.building_unit.upcase
    @unit.save
    assert_not duplicate_bldg.valid?
  end

end
