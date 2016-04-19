require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class BuildingTest < ActiveSupport::TestCase
  def setup
    @bldg = build(:building)
  end

  test "should be valid" do
    assert @bldg.valid?
  end

  test "street address should be present" do
    @bldg.formatted_street_address = "     "
    assert_not @bldg.valid?
  end

  test "route should be present" do
    @bldg.route = "     "
    assert_not @bldg.valid?
  end

  test "administrative_area_level_1_short should be present" do
    @bldg.administrative_area_level_1_short = "     "
    assert_not @bldg.valid?
  end

  test "country_short should be present" do
    @bldg.country_short = "     "
    assert_not @bldg.valid?
  end

  test "postal_code should be present" do
    @bldg.postal_code = "     "
    assert_not @bldg.valid?
  end

  test "lat should be present" do
    @bldg.lat = "     "
    assert_not @bldg.valid?
  end

  test "lng should be present" do
    @bldg.lng = "     "
    assert_not @bldg.valid?
  end

  test "place_id should be present" do
    @bldg.place_id = "     "
    assert_not @bldg.valid?
  end

  test "company should be present" do
    @bldg.company = nil
    assert_not @bldg.valid?
  end

  test "formatted_street_address should not be too long" do
    @bldg.formatted_street_address = "a" * 201
    assert_not @bldg.valid?
  end

  test "street_number should not be too long" do
    @bldg.street_number = "a" * 21
    assert_not @bldg.valid?
  end

  test "route should not be too long" do
    @bldg.route = "a" * 101
    assert_not @bldg.valid?
  end

  test "administrative_area_level_2_short should not be too long" do
    @bldg.administrative_area_level_2_short = "a" * 101
    assert_not @bldg.valid?
  end

  test "administrative_area_level_1_short should not be too long" do
    @bldg.administrative_area_level_1_short = "a" * 101
    assert_not @bldg.valid?
  end

  test "postal_code should not be too long" do
    @bldg.postal_code = "a" * 16
    assert_not @bldg.valid?
  end

  test "lat should not be too long" do
    @bldg.lat = "a" * 101
    assert_not @bldg.valid?
  end

  test "lng should not be too long" do
    @bldg.lng = "a" * 101
    assert_not @bldg.valid?
  end

  test "place_id should not be too long" do
    @bldg.place_id = "a" * 101
    assert_not @bldg.valid?
  end

  test "street_address return street number and route" do
    assert @bldg.street_address, @bldg.street_number + ' ' + @bldg.route
  end

  test "archive sets the model to archived" do
    @bldg.archive
    assert_equal true, @bldg.reload.archived
  end

  test "find_unarchived does not return archived results" do
    @bldg.save
    assert_not_nil Building.find_unarchived(@bldg.id)
    @bldg.archive
    assert_raises(ActiveRecord::RecordNotFound) { Building.find_unarchived(@bldg.id) }
  end

  test "search can find address" do
    @bldgs = Building.search("Franklin Ave, Brooklyn, NY 11238", 'active')
    assert @bldgs.length, 1
  end

  test "save and add neighborhood creates neighborhood" do
    n2 = @bldg.find_or_create_neighborhood('Crown Heights', 'Brooklyn', 'New York', 'NY')
    n = Neighborhood.find_by(name: 'Crown Heights')
    assert n
    assert @bldg.neighborhood.name, n.name
  end

  # TODO: finish writing tests...
end
