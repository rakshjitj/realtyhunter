require 'test_helper'

class BuildingTest < ActiveSupport::TestCase
  def setup
  	@company = companies(:one)
  	@company2 = companies(:two)

  	@office = offices(:one)
  	@office2 = offices(:two)
		@office.company = @company
		@office2.company = @company2

		@landlord = landlords(:one)
		@landlord2 = landlords(:two)
		@landlord.company = @company
		@landlord2.company = @company2

  	@building = buildings(:one)
  	@building2 = buildings(:two)
  	@building.company = @company
  	@building2.company = @company2
  	@building.landlord = @landlord
  	@building2.landlord = @landlord2

  	@user = users(:michael)
  	@user2 = users(:mallory)
  	@manager = users(:archer)
  	@manager.make_manager
  	@company_admin = users(:lana)
  	@company_admin.make_company_admin
  	
  	@user.company = @company

  	@manager.company = @company
  	@company_admin.company = @company
  	@user2.company = @company2

  	@runit = ResidentialUnit.new({
    	beds: 1,
    	baths: 1,
      listing_id: 1111,
      building_unit: "1111",
      rent: 10,
      building: @building,
      pet_policy: @pet_policy
    	})
  	@runit2 = ResidentialUnit.new({
    	beds: 1,
    	baths: 1,
      listing_id: 2222,
      building_unit: "2222",
      rent: 10,
      building: @building2,
      pet_policy: @pet_policy
    	})

  	@cunit = CommercialUnit.new({
  		listing_id: 3333,
  		building: @building,
  		rent: 10,
  		construction_status: "existing",
  		lease_type: "full_service",
  		sq_footage: 123,
  		floor: 1,
  		building_size: 1
  		})

  	@cunit2 = CommercialUnit.new({
  		listing_id: 3333,
  		building: @building2,
  		rent: 10,
  		construction_status: "existing",
  		lease_type: "full_service",
  		sq_footage: 123,
  		floor: 1,
  		building_size: 1
  		})
  end

  test "user can only edit their profile" do
	  ability = Ability.new(@user)
	  assert ability.can?(:manage, @user)
	  assert ability.cannot?(:manage, @manager)
	end

	test "user can only delete their profile" do
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

	test "company admins cannot manage residential units from their company" do
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

	test "managers cannot manage commercial units from their company" do
		ability = Ability.new(@manager)
	  assert ability.cannot?(:manage, @cunit2)
	end

	test "company admins can manage commercial units from their company" do
		ability = Ability.new(@company_admin)
	  assert ability.can?(:manage, @cunit)
	end

	test "company admins cannot manage commercial units from their company" do
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

end