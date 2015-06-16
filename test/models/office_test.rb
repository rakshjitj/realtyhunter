require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class OfficeTest < ActiveSupport::TestCase

  def setup
    @office = build(:office)
  end

  test "should be valid" do
    assert @office.valid?
  end

  test "formatted_street_address should be present" do
    @office.formatted_street_address = "     "
    assert_not @office.valid?
  end

  test "street_number should be present" do
    @office.street_number = "     "
    assert_not @office.valid?
  end

  test "route should be present" do
    @office.route = "     "
    assert_not @office.valid?
  end


  test "administrative_area_level_2_short should be present" do
    @office.administrative_area_level_2_short = "     "
    assert_not @office.valid?
  end

  test "administrative_area_level_1_short should be present" do
    @office.administrative_area_level_1_short = "     "
    assert_not @office.valid?
  end

  test "postal_code should be present" do
    @office.postal_code = "     "
    assert_not @office.valid?
  end

  test "country_short should be present" do
    @office.country_short = "     "
    assert_not @office.valid?
  end

  test "lat should be present" do
    @office.lat = "     "
    assert_not @office.valid?
  end

  test "lng should be present" do
    @office.lng = "     "
    assert_not @office.valid?
  end

  test "place_id should be present" do
    @office.place_id = "     "
    assert_not @office.valid?
  end

  test "name should not be too long" do
    @office.name = "a" * 101
    assert_not @office.valid?
  end

  test "formatted_street_address should not be too long" do
    @office.formatted_street_address = "a" * 201
    assert_not @office.valid?
  end

  test "street_number should not be too long" do
    @office.street_number = "a" * 21
    assert_not @office.valid?
  end

  test "route should not be too long" do
    @office.route = "a" * 101
    assert_not @office.valid?
  end

  test "administrative_area_level_2_short should not be too long" do
    @office.administrative_area_level_2_short = "a" * 101
    assert_not @office.valid?
  end

  test "administrative_area_level_1_short should not be too long" do
    @office.administrative_area_level_1_short = "a" * 101
    assert_not @office.valid?
  end

  test "postal_code should not be too long" do
    @office.postal_code = "a" * 16
    assert_not @office.valid?
  end

  test "lat should not be too long" do
    @office.lat = "a" * 101
    assert_not @office.valid?
  end

  test "lng should not be too long" do
    @office.lng = "a" * 101
    assert_not @office.valid?
  end

  test "place_id should not be too long" do
    @office.place_id = "a" * 101
    assert_not @office.valid?
  end

  test "name should be unique" do
    duplicate_user = @office.dup
    duplicate_user.name = @office.name.upcase
    @office.save
    assert_not duplicate_user.valid?
  end

  test "formatted_street_address should be unique" do
    duplicate_bldg = @office.dup
    duplicate_bldg.formatted_street_address = @office.formatted_street_address
    @office.save
    assert_not duplicate_bldg.valid?
  end

  test "telephone validation should accept valid phone numbers" do
    valid_phones = %w[(555)555-5566 555.555.5555 5555555555 555-555-5555]
    valid_phones.each do |valid_phone|
      @office.telephone = valid_phone
      assert @office.valid?, "#{valid_phone.inspect} should be valid"
    end
  end

  test "telephone validation should reject invalid phone numbers" do
    valid_phones = %w[555-555-55-55 (555)555-555]
    valid_phones.each do |valid_phone|
      @office.telephone = valid_phone
      assert_not @office.valid?, "#{valid_phone.inspect} should be invalid"
    end
  end

  test "archive sets the model to archived" do
    @office.archive
    assert_equal true, @office.reload.archived
  end

  test "find_unarchived does not return archived results" do
    @office.save
    assert_not_nil Office.find_unarchived(@office.id)
    @office.archive
    assert_raises(ActiveRecord::RecordNotFound) { Office.find_unarchived(@office.id) }
  end

  test "managers gets all managers for this office" do
    michael = create(:user, company: @office.company)
    archer = create(:user, company: @office.company)
    @office.users = [michael, archer]
    michael.make_manager
    assert true, michael.is_manager?
    assert_equal 1, @office.managers.count
  end

  test "agents gets all agents for this office" do
    michael = create(:user, company: @office.company)
    archer = create(:user, company: @office.company)
    @office.users = [michael, archer]
    michael.make_manager
    assert_equal 1, @office.agents.count
  end

end
