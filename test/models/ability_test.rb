require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  def setup
  	@company = create(:company)
  	@company2 = create(:company)

  	@office = create(:office, company: @company)
  	@office2 = create(:office)

  	@landlord = build(:landlord, company: @company)
  	@landlord2 = build(:landlord)
  	@building = create(:building, landlord: @landlord, company: @company)
  	@building2 = create(:building, landlord: @landlord2)

  	@user = build(:user, company: @company)
  	@user2 = build(:user)
  	@manager = build(:user, company: @company)
  	@manager.make_manager
  	@company_admin = build(:user, company: @company)
  	@company_admin.make_company_admin
  	@user.add_role :residential
  	@user2.add_role :residential
  	@manager.add_role :residential
  	@company_admin.add_role :residential
  	@user.add_role :commercial
  	@user2.add_role :commercial
  	@manager.add_role :commercial
  	@company_admin.add_role :commercial

  	@external_vendor = create(:user)
  	@external_vendor.employee_title = EmployeeTitle.find_by(name: 'external vendor')
  	@external_vendor.update_roles

  	@unit = create(:unit,
      building: @building,
      rent: 10)
    @unit2 = create(:unit,
      building: @building2,
      rent: 20)

    @runit = create(:residential_listing, unit: @unit)
    @runit2 = create(:residential_listing, unit: @unit2)
    @cunit = create(:commercial_listing, unit: @unit)
    @cunit2 = create(:commercial_listing, unit: @unit2)
  end

  test "external vendors can access their profile" do
  	ability = Ability.new(@external_vendor)
	  assert ability.can?(:manage, @external_vendor)
	  assert ability.cannot?(:manage, @manager)
  end

  test "external vendors cannot access listings" do
  	ability = Ability.new(@external_vendor)
	  assert ability.cannot?(:read, @runit)
	  assert ability.cannot?(:read, @cunit)
	  assert ability.cannot?(:read, @building)
	  assert ability.cannot?(:read, @landlord)
	  assert ability.cannot?(:manage, @runit)
	  assert ability.cannot?(:manage, @cunit)
	  assert ability.cannot?(:manage, @building)
	  assert ability.cannot?(:manage, @landlord)
  end

  # save?
  test "user can only edit their profile" do
  	@manager.save
  	@user.save
	  ability = Ability.new(@user)
	  assert ability.can?(:manage, @user)
	  assert ability.cannot?(:manage, @manager)
	end

	# save?
	test "user can only delete their profile" do
		@manager.save
  	@user.save
	  ability = Ability.new(@user)
	  assert ability.can?(:destroy, @user)
	  assert ability.cannot?(:destroy, @manager)
	end

	test "user can view their company" do
	  ability = Ability.new(@user)
	  assert ability.can?(:read, @company)
	end

	test "user cannot view other companies" do
	  ability = Ability.new(@user)
	  assert ability.cannot?(:read, @company2)
	end

	test "user can view other employees from their company" do
		ability = Ability.new(@user)
	  assert ability.can?(:read, @manager)
	end

	test "user cannot view employees from other companies" do
		ability = Ability.new(@user)
	  assert ability.can?(:read, @user2)
	end

	test "only company admin can edit company" do
	  user_ability = Ability.new(@user)
	  manager_ability = Ability.new(@manager)
	  admin_ability = Ability.new(@company_admin)
	  assert admin_ability.can?(:manage, @company)
	  assert manager_ability.cannot?(:manage, @company)
	  assert user_ability.cannot?(:manage, @company)
	end

	test "company admin cannot manage other companies" do
		ability = Ability.new(@company_admin)
		assert ability.can?(:read, @company)
	  assert ability.cannot?(:read, @company2)
	end

	test "user can view offices in their company" do
		ability = Ability.new(@user)
	  assert ability.can?(:read, @office)
	end

	test "user cannot view offices in other companies" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:read, @office2)
	end

	test "user cannot manage any offices" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:manage, @office)
	end

	test "company admin can manage offices in their company" do
		ability = Ability.new(@company_admin)
		assert ability.can?(:manage, @office)
	end

	test "company admin cannot manage offices in other companies" do
		ability = Ability.new(@company_admin)
	  assert ability.cannot?(:manage, @office2)
	end

	test "managers cannot manage offices in their company" do
		ability = Ability.new(@manager)
	  assert ability.cannot?(:manage, @office)
	end

	test "managers cannot manage offices in other companies" do
		ability = Ability.new(@manager)
	  assert ability.cannot?(:manage, @office2)
	end

	test "company admin can manage buildings from their company" do
		ability = Ability.new(@company_admin)
	  assert ability.can?(:manage, @building)
	end

	test "company admin cannot manage buildings from other companies" do
		ability = Ability.new(@company_admin)
	  assert ability.cannot?(:manage, @building2)
	end

	test "users can view buildings from their company" do
		ability = Ability.new(@user)
	  assert ability.can?(:read, @building)
	end

	test "users cannot view buildings from other companies" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:read, @building2)
	end

	# ----------- Residential Units -----------------------------
	test "users can view residential units from their company" do
		ability = Ability.new(@user)
	  assert ability.can?(:read, @runit)
	end

	test "users cannot view residential units from other companies" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:read, @runit2)
	end

	test "users cannot manage residential units from their company" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:manage, @runit)
	end

	test "users cannot manage residential units from other companies" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:manage, @runit2)
	end

	test "managers can manage residential units from their company" do
		ability = Ability.new(@manager)
	  assert ability.can?(:manage, @runit)
	end

	test "managers cannot manage residential units from their company" do
		ability = Ability.new(@manager)
	  assert ability.cannot?(:manage, @runit2)
	end

	test "company admins can manage residential units from their company" do
		ability = Ability.new(@company_admin)
	  assert ability.can?(:manage, @runit)
	end

	test "company admins cannot manage residential units from another company" do
		ability = Ability.new(@company_admin)
	  assert ability.cannot?(:manage, @runit2)
	end

	# ----------- Commercial Units -----------------------------
	test "users can view commercial units from their company" do
		ability = Ability.new(@user)
	  assert ability.can?(:read, @cunit)
	end

	test "users cannot view commercial units from other companies" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:read, @cunit2)
	end

	test "users cannot manage commercial units from their company" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:manage, @cunit)
	end

	test "users cannot manage commercial units from other companies" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:manage, @cunit2)
	end

	test "managers can manage commercial units from their company" do
		ability = Ability.new(@manager)
	  assert ability.can?(:manage, @cunit)
	end

	test "managers cannot manage commercial units from other companies" do
		ability = Ability.new(@manager)
	  assert ability.cannot?(:manage, @cunit2)
	end

	test "company admins can manage commercial units from their company" do
		ability = Ability.new(@company_admin)
	  assert ability.can?(:manage, @cunit)
	end

	test "company admins cannot manage commercial units from other companies" do
		ability = Ability.new(@company_admin)
	  assert ability.cannot?(:manage, @cunit2)
	end

	# ----------- Landlords -----------------------------
	test "users cannot view landlords from their company" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:read, @landlord)
	end

	test "users cannot view landlords from other companies" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:read, @landlord2)
	end

	test "users cannot manage landlords from their company" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:manage, @landlord)
	end

	test "users cannot manage landlords from other companies" do
		ability = Ability.new(@user)
	  assert ability.cannot?(:manage, @landlord2)
	end

	test "managers can view landlords from their company" do
		ability = Ability.new(@manager)
		assert_equal @manager.company_id, @landlord.company_id
	  assert ability.can?(:read, @landlord)
	end

	test "managers cannot view landlords from other companies" do
		ability = Ability.new(@manager)
	  assert ability.cannot?(:read, @landlord2)
	end

	test "company admins can manage landlords from their company" do
		ability = Ability.new(@company_admin)
	  assert ability.can?(:manage, @landlord)
	end

	test "company admins cannot manage landlords from other companies" do
		ability = Ability.new(@company_admin)
	  assert ability.cannot?(:manage, @landlord2)
	end

	# TODO: data-entry, api tests
end
