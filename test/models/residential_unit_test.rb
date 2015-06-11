require 'test_helper'

class ResidentialUnitTest < ActiveSupport::TestCase
  def setup
  	# fixtures not working, MTI messes things up
    #puts "11111 #{Neighborhood.all.count}"

    @n = neighborhoods(:one)
    @n2 = neighborhoods(:two)

    @building = buildings(:one)
    @building.neighborhood_id = @n.id

    @building2 = buildings(:two)
    @building2.neighborhood = @n2

    @pet_policy = pet_policies(:three)

    @unit = ResidentialUnit.new({
    	beds: 1,
    	baths: 1,
      listing_id: 1111,
      building_unit: "1111",
      rent: 10,
      building: @building,
      pet_policy: @pet_policy
    	})
    @unit2 = ResidentialUnit.new({
      beds: 5,
      baths: 5,
      listing_id: 2222,
      building_unit: "2222",
      rent: 20,
      building: @building2,
      pet_policy: @pet_policy
      })
    @unit3 = ResidentialUnit.new({
      beds: 8,
      baths: 8,
      listing_id: 3333,
      building_unit: "3333",
      rent: 30,
      building: @building2,
      pet_policy: @pet_policy
      })
  end

  test "should be valid" do
    assert @unit.valid?
  end

  test "building_unit should be present" do
    @unit.building_unit = "     "
    assert_not @unit.valid?
  end

  test "lease_duration should be present" do
    @unit.lease_duration = "     "
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

  test "duplicate should copy all info" do
    @unit.save
    unit_dup = @unit.duplicate('999999', true)
    assert_not_equal unit_dup.id, @unit.id
    assert_not_equal unit_dup.id, nil
    assert_not_equal unit_dup.listing_id, @unit.listing_id
    assert unit_dup.building_id, @unit.building_id
    assert unit_dup.building_unit, '999999'
  end

  test "search by address restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:address] = @building.formatted_street_address
    @results = ResidentialUnit.search(params)
    assert_equal 1, @results.length
    assert @results[0].building.formatted_street_address, @building.formatted_street_address
  end

  test "search by min rent restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    # all search params come in as strings from the url
    params[:rent_min] = "#{@unit2.rent-2}"
    @results = ResidentialUnit.search(params)
    assert_equal 2, @results.length
    assert @results[0].rent, @unit2.rent
  end

  test "search by max rent restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:rent_max] = "#{@unit.rent+2}"
    @results = ResidentialUnit.search(params)
    assert_equal 1, @results.length
    assert @results[0].rent, @unit.rent
  end

  test "search by min and max rent restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:rent_min] = "#{@unit2.rent-2}"
    params[:rent_max] = "#{@unit2.rent+2}"
    @results = ResidentialUnit.search(params)
    assert_equal 1, @results.length
    assert @results[0].rent, @unit2.rent
  end

  test "search by min beds restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:bed_min] = "#{@unit2.beds-2}"
    @results = ResidentialUnit.search(params)
    assert_equal 2, @results.length
    assert @results[0].beds, @unit2.beds
  end

  test "search by max beds restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:bed_max] = "#{@unit.beds+2}"
    @results = ResidentialUnit.search(params)
    assert_equal 1, @results.length
    assert @results[0].beds, @unit.beds
  end

  test "search by min and max beds restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:bed_min] = "#{@unit2.beds-2}"
    params[:bed_max] = "#{@unit2.beds+2}"
    @results = ResidentialUnit.search(params)
    assert_equal 1, @results.length
    assert @results[0].beds, @unit2.beds
  end

  test "search by min baths restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:bath_min] = "#{@unit2.baths-2}"
    @results = ResidentialUnit.search(params)
    assert_equal 2, @results.length
    assert @results[0].baths, @unit2.baths
  end

  test "search by max baths restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:bath_max] = "#{@unit.baths+2}"
    @results = ResidentialUnit.search(params)
    assert_equal 1, @results.length
    assert @results[0].baths, @unit.baths
  end

  test "search by min and max baths restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:bath_min] = "#{@unit2.baths-2}"
    params[:bath_max] = "#{@unit2.baths+2}"
    @results = ResidentialUnit.search(params)
    assert_equal 1, @results.length
    assert @results[0].baths, @unit2.baths
  end

  test "search by building unit restricts returned results" do
    @unit.save
    @unit2.save
    @unit3.save
    params = {}
    params[:unit] = "#{@unit.building_unit}"
    @results = ResidentialUnit.search(params)
    assert_equal 1, @results.length
    assert @results[0].building_unit, @unit.building_unit
  end

  test "search by neighborhood restricts returned results" do
    params = {}
    params[:neighborhoods] = "#{@unit.building.neighborhood.id}, #{@unit2.building.neighborhood.id}"
    @results = ResidentialUnit.search(params)
    assert_equal ResidentialUnit.all.length, @results.length
  end

  test "search by features restricts returned results" do
    params = {}
    params[:features] = "gym, elevator"
    @results = ResidentialUnit.search(params)
    assert_equal ResidentialUnit.all.length, @results.length
  end

  test "take off market makes unit unavailable" do
    assert "active", @unit.status
    @unit.take_off_market(Date.new)
    assert "off", @unit.status
    assert Date.new, @unit.available_by
  end

  test "calc_lease_end_date returns the correct date" do
    @unit.lease_duration = "year"
    one_yr = Date.new + 12.months
    assert one_yr, @unit.calc_lease_end_date
  end

  # TODO: set_location_data

end
