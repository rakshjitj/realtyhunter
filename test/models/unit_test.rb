require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class UnitTest < ActiveSupport::TestCase
  def setup
    @company = build_stubbed(:company)
    @user = create(:user, company: @company)
    # want each to have diff addresses, so generate diff buildings
    @building = create(:building, company: @company)
    @building2 = create(:building, company: @company)
    @building3 = create(:building, company: @company)
    @unit = create(:unit,
      building: @building,
      rent: 10)
    # @unit2 = build(:unit,
    #   building: @building2,
    #   rent: 20)
    # @unit3 = build(:unit,
    #   building: @building3,
    #   rent: 30)
  end

  test "should be valid" do
    @unit.errors.inspect
    assert @unit.valid?
  end

  test "rent should be present" do
    @unit.rent = "     "
    assert_not @unit.valid?
  end

  test "building_unit should not be too long" do
    @unit.building_unit = "a" * 51
    assert_not @unit.valid?
  end

  # todo: finish...
end
