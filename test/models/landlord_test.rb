require 'test_helper'

class LandlordTest < ActiveSupport::TestCase

	def setup
    @landlord = landlords(:one)
  end

  test "should be valid" do
    assert @landlord.valid?
  end

  test "code should be present" do
    @landlord.code = "     "
    assert_not @landlord.valid?
  end

  test "name should be present" do
    @landlord.name = "     "
    assert_not @landlord.valid?
  end

  test "mobile should be present" do
    @landlord.mobile = "     "
    assert_not @landlord.valid?
  end

  test "email should be present" do
    @landlord.email = "     "
    assert_not @landlord.valid?
  end

  test "months_required should be present" do
    @landlord.months_required = "     "
    assert_not @landlord.valid?
  end

	test "code should be unique" do
    duplicate_landlord = @landlord.dup
    duplicate_landlord.code = @landlord.code.upcase
    @landlord.save
    assert_not duplicate_landlord.valid?
  end

  test "name should be unique" do
    duplicate_landlord = @landlord.dup
    duplicate_landlord.name = @landlord.name.upcase
    @landlord.save
    assert_not duplicate_landlord.valid?
  end

  test "email should be unique" do
    duplicate_landlord = @landlord.dup
    duplicate_landlord.email = @landlord.email.upcase
    @landlord.save
    assert_not duplicate_landlord.valid?
  end

	test "code should not be too long" do
    @landlord.code = "a" * 101
    assert_not @landlord.valid?
  end

  test "name should not be too long" do
    @landlord.name = "a" * 101
    assert_not @landlord.valid?
  end

  test "mobile should not be too long" do
    @landlord.mobile = "a" * 21
    assert_not @landlord.valid?
  end

  test "office_phone should not be too long" do
    @landlord.office_phone = "a" * 21
    assert_not @landlord.valid?
  end

  test "fax should not be too long" do
    @landlord.fax = "a" * 21
    assert_not @landlord.valid?
  end

  test "email should not be too long" do
    @landlord.email = "a" * 101
    assert_not @landlord.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @landlord.email = valid_address
      assert @landlord.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @landlord.email = invalid_address
      assert_not @landlord.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @landlord.email = mixed_case_email
    @landlord.save
    assert_equal mixed_case_email.downcase, @landlord.reload.email
  end

   test "phone validation should accept valid phone numbers" do
    valid_phones = %w[(555)555-5555 555.555.5555 5555555555 555-555-5555]
    valid_phones.each do |valid_phone|
      @landlord.office_phone = valid_phone
      assert @landlord.valid?, "#{valid_phone.inspect} should be valid"
    end
  end

  test "phone validation should reject invalid phone numbers" do
    valid_phones = %w[555-555-55-55 (555)555-555]
    valid_phones.each do |valid_phone|
      @landlord.mobile = valid_phone
      assert_not @landlord.valid?, "#{valid_phone.inspect} should be invalid"
    end
  end
end
