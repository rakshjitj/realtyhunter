require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class ResidentialListingTest < ActiveSupport::TestCase
  def setup
    @company = create(:company)
    @user = create(:user, company: @company)
    # want each to have diff addresses, so generate diff buildings
    @building = create(:building_with_building_amenities,
      company: @company,
      street_number: '722',
      route: 'Franklin Ave')

    @building2 = create(:building_with_building_amenities,
      company: @company)
    @building3 = create(:building_with_building_amenities,
      company: @company)

    @unit = create(:unit,
      building: @building,
      building_unit: '1',
      rent: 10)
    @unit2 = create(:unit,
      building: @building2,
      rent: 20)
    @unit3 = create(:unit,
      building: @building3,
      rent: 30)

    @runit = create(:residential_listing,
        unit: @unit,
        beds: 1,
        baths: 1)
    @runit2 = create(:residential_listing,
        unit: @unit2,
        beds: 5,
        baths: 5)
    @runit3 = create(:residential_listing,
        unit: @unit3,
        beds: 8,
        baths: 8)
  end

 #  test "should be valid" do
 #    assert @runit.valid?
 #  end

 #  test "lease_start should be present" do
 #    @runit.lease_start = "     "
 #    assert_not @runit.valid?
 #  end

 #  test "lease_end should be present" do
 #    @runit.lease_end = "     "
 #    assert_not @runit.valid?
 #  end

	# test "beds should be present" do
 #    @runit.beds = "     "
 #    assert_not @runit.valid?
 #  end

 #  test "baths should be present" do
 #    @runit.baths = "     "
 #    assert_not @runit.valid?
 #  end

 #  test "beds should not be too many" do
 #    @runit.beds = 12
 #    assert_not @runit.valid?
 #  end

 #  test "baths should not be too many" do
 #    @runit.baths = 12
 #    assert_not @runit.valid?
 #  end

 #  test "archive should update archived flag" do
 #    assert @runit.unit.archived == false
 #    @runit.archive
 #    assert @runit.unit.archived == true
 #  end

 #  test "find_unarchived should only return active listings" do
 #    assert @runit.unit.archived == false
 #    assert_equal ResidentialListing.find_unarchived(@runit.id), @runit
 #    @runit.unit.archive
 #    assert_nil ResidentialListing.find_unarchived(@runit.id)
 #  end

  # test "street_address_and_unit formats address info" do
  #   assert_equal @runit.street_address_and_unit, "722 Franklin Ave #1"

  #   found_unit = ResidentialListing.joins(unit: :building).where(id: @runit.id)
  #       .select('buildings.street_number', 'buildings.route', 'units.building_unit')
  #   assert_equal found_unit[0].street_address_and_unit, "722 Franklin Ave #1"

  #   @runit.unit.building_unit = ''
  #   @runit.save
  #   assert_equal @runit.street_address_and_unit, "722 Franklin Ave"
  #   found_unit = ResidentialListing.joins(unit: :building).where(id: @runit.id)
  #       .select('buildings.street_number', 'buildings.route', 'units.building_unit')
  #   assert_equal found_unit[0].street_address_and_unit, "722 Franklin Ave"
  # end

  # test "street_address formats address info" do
  #   assert_equal @runit.street_address, "722 Franklin Ave"

  #   found_unit = ResidentialListing.joins(unit: :building).where(id: @runit.id)
  #       .select('buildings.street_number', 'buildings.route')
  #   assert_equal found_unit[0].street_address, "722 Franklin Ave"
  # end

  # test "amenities_to_s returns a concatenated string of residential amenities" do
  #   assert @runit.amenities_to_s, "None"

  #   @runit.residential_amenities << ResidentialAmenity.all.limit(4)
  #   assert_equal 3, @runit.amenities_to_s.count(',')
  # end

  # test "all_amenities_to_s returns a concatenated string of all amenities" do
  #   assert @runit.all_amenities_to_s, "None"

  #   @runit.residential_amenities << ResidentialAmenity.all.limit(2)
  #   @runit.unit.building.building_amenities << BuildingAmenity.all.limit(2)
  #   @runit.save
  #   assert_equal 3, @runit.all_amenities_to_s.count(',')
  # end

  # test "listings_by_neighborhoods groups by neighborhood" do
  #   @user.save
  #   @building.save
  #   @building2.save
  #   @building3.save
  #   @unit.save
  #   @unit2.save
  #   @unit3.save
  #   @runit.save
  #   @runit2.save
  #   @runit3.save

  #   output = ResidentialListing.listings_by_neighborhood(@user, Unit.all.pluck(:listing_id))
  #   assert_equal 3, output.length
  # end

  test "listings_by_id only returns listings that match our list of ids" do
    @user.save
    @building.save
    @building2.save
    @building3.save
    @unit.save
    @unit2.save
    @unit3.save
    @runit.save
    @runit2.save
    @runit3.save

    output = ResidentialListing.listings_by_id(@user, [@unit.listing_id])
    assert_equal 1, output.length
    assert @runit.id, output[0].id
  end

  # test "search by address restricts returned results" do
  #   # @runit.save
  #   # @runit2.save
  #   # @runit3.save
  #   params = {}
  #   params[:address] = @building.formatted_street_address

  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 1, results.length
  #   assert results[0].unit.building.formatted_street_address, @building.formatted_street_address
  # end

  # test "search by min rent restricts returned results" do
  #   # @runit.save
  #   # @runit2.save
  #   # @runit3.save
  #   params = {}
  #   # all search params come in as strings from the url
  #   params[:rent_min] = "#{@runit2.unit.rent-2}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 2, results.length
  #   assert results[0].unit.rent, @runit2.unit.rent
  # end

  # test "search by max rent restricts returned results" do
  #   # @runit.save
  #   # @runit2.save
  #   # @runit3.save
  #   params = {}
  #   params[:rent_max] = "#{@runit.unit.rent+2}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 1, results.length
  #   assert results[0].unit.rent, @runit.unit.rent
  # end

  # test "search by min and max rent restricts returned results" do
  #   # @runit.save
  #   # @runit2.save
  #   # @runit3.save
  #   params = {}
  #   params[:rent_min] = "#{@runit2.unit.rent-2}"
  #   params[:rent_max] = "#{@runit2.unit.rent+2}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 1, results.length
  #   assert results[0].rent, @runit2.unit.rent
  # end

  # test "search by min beds restricts returned results" do
  #   # @runit.save
  #   # @runit2.save
  #   # @runit3.save
  #   params = {}
  #   params[:bed_min] = "#{@runit2.beds-2}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 2, results.length
  #   assert results[0].beds, @runit2.beds
  # end

  # test "search by max beds restricts returned results" do
  #   # @runit.save
  #   # @runit2.save
  #   # @runit3.save
  #   params = {}
  #   params[:bed_max] = "#{@runit.beds+2}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 1, results.length
  #   assert results[0].beds, @runit.beds
  # end

  # test "search by min and max beds restricts returned results" do
  #   # @runit.save
  #   # @runit2.save
  #   # @runit3.save
  #   params = {}
  #   params[:bed_min] = "#{@runit2.beds-2}"
  #   params[:bed_max] = "#{@runit2.beds+2}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 1, results.length
  #   assert results[0].beds, @runit2.beds
  # end

  # test "search by min baths restricts returned results" do
  #   # @runit.save
  #   # @runit2.save
  #   # @runit3.save
  #   params = {}
  #   params[:bath_min] = "#{@runit2.baths-2}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 2, results.length
  #   assert results[0].baths, @runit2.baths
  # end

  # test "search by max baths restricts returned results" do
  #   @runit.save
  #   @runit2.save
  #   @runit3.save
  #   params = {}
  #   params[:bath_max] = "#{@runit.baths+2}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 1, results.length
  #   assert results[0].baths, @runit.baths
  # end

  # test "search by min and max baths restricts returned results" do
  #   @runit.save
  #   @runit2.save
  #   @runit3.save
  #   params = {}
  #   params[:bath_min] = "#{@runit2.baths-2}"
  #   params[:bath_max] = "#{@runit2.baths+2}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 1, results.length
  #   assert results[0].baths, @runit2.baths
  # end

  # test "search by building unit restricts returned results" do
  #   @runit.save
  #   @runit2.save
  #   @runit3.save
  #   params = {}
  #   params[:unit] = "#{@runit.unit.building_unit}"
  #   results = ResidentialListing.search(params, @user)
  #   assert_equal 1, results.length
  #   assert results[0].building_unit, @runit.unit.building_unit
  # end

  # test "search by neighborhood restricts returned results" do
  #   params = {
  #     neighborhood_ids: "#{@runit.unit.building.neighborhood.id}"
  #   }
  #   results = ResidentialListing.search(params, @user)
  #   assert results.length < ResidentialListing.all.length
  # end

  # # test "search by features restricts returned results" do
  # #   @building.save
  # #   params = {
  # #     building_feature_ids: @building.building_amenities.ids.join(',') #BuildingAmenity.all.ids.join(',')
  # #   }
  # #   puts "\n\n\n #{params.inspect} #{@building.building_amenities.inspect}"
  # #   results = ResidentialListing.search(params, @user)
  # #   #assert ResidentialListing.all.length < results.length
  # # end

  # test "duplicate should copy all info" do
  #   @runit.save
  #   unit_dup = @runit.duplicate('999999', true)
  #   assert_not_equal unit_dup.id, @runit.id
  #   assert_not_equal unit_dup.id, nil
  #   assert_not_equal unit_dup.unit.listing_id, @runit.unit.listing_id
  #   assert unit_dup.unit.building_id, @runit.unit.building_id
  #   assert unit_dup.unit.building_unit, '999999'
  #   # TODO: need test images in order to exercise this code fully
  #   assert_equal @runit.unit.images.length, unit_dup.unit.images.length
  #   #assert_equal @runit.images[0].unit_id, unit_dup.images[0].unit_id
  # end

  # test "take off market makes unit unavailable" do
  #   assert "active", @runit.unit.status
  #   @runit.take_off_market(Date.new)
  #   assert "off", @runit.unit.status
  #   assert Date.new, @runit.unit.available_by
  # end

  # TODO: set_location_data

end
