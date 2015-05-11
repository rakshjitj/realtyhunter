require 'test_helper'

class OfficeTest < ActiveSupport::TestCase

  def setup
    @office = Office.new(
    	name: "Prospect Heights", 
    	street_address: "722 Franklin Ave", 
    	city: "Brooklyn", 
    	state: "NY", 
    	zipcode: "11238",
    	telephone: "(813)495-2570",
    	fax: "(813)495-2570"
   )
  end

  test "should be valid" do
    assert @office.valid?
  end

  test "street_address should be present" do
    @office.street_address = "     "
    assert_not @office.valid?
  end

  test "city should be present" do
    @office.city = "     "
    assert_not @office.valid?
  end

  test "state should be present" do
    @office.state = "  "
    assert_not @office.valid?
  end

  test "zipcode should be present" do
    @office.zipcode = "     "
    assert_not @office.valid?
  end

  test "telphone should be present" do
    @office.telephone = "     "
    assert_not @office.valid?
  end

  test "name should not be too long" do
    @office.name = "a" * 101
    assert_not @office.valid?
  end

  test "street_address should not be too long" do
    @office.street_address = "a" * 101
    assert_not @office.valid?
  end

  test "city should not be too long" do
    @office.city = "a" * 101
    assert_not @office.valid?
  end

  test "state should not be too long" do
    @office.state = "a" * 3
    assert_not @office.valid?
  end

  test "state should not be too short" do
    @office.state = "a"
    assert_not @office.valid?
  end

  test "zipcode should not be too long" do
    @office.zipcode = "a" * 11
    assert_not @office.valid?
  end

  test "zipcode should not be too short" do
    @office.zipcode = "a" * 4
    assert_not @office.valid?
  end

  test "telephone should not be too long" do
    @office.telephone = "a" * 11
    assert_not @office.valid?
  end

  test "telephone validation should accept valid phone numbers" do
    valid_phones = %w[(555)555-5555 555.555.5555 5555555555 555-555-5555]
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

  test "street addresses should be unique" do
    duplicate_user = @office.dup
    duplicate_user.street_address = @office.street_address.upcase
    @office.save
    assert_not duplicate_user.valid?
  end

  test "name should be unique" do
    duplicate_user = @office.dup
    duplicate_user.name = @office.name.upcase
    @office.save
    assert_not duplicate_user.valid?
  end

end
