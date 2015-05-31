require 'test_helper'

class ResidentialUnitTest < ActiveSupport::TestCase
  def setup
  	# fixtures not working, MTI messes things up
    @unit = ResidentialUnit.new({
    	beds: 1,
    	baths: 2,
      listing_id: 1111,
      building_unit: "sfddsfds",
      rent: 1,
      building_id: 1,
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

  test "duplicate should copy all info" do
    @unit.save
    unit_dup = @unit.duplicate('999999', true)
    assert_not_equal unit_dup.id, @unit.id
    assert_not_equal unit_dup.id, nil
    assert_not_equal unit_dup.listing_id, @unit.listing_id
    assert unit_dup.building_id, @unit.building_id
    assert unit_dup.building_unit, '999999'
  end

end
