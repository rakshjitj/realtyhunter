require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @res_agent_type = create(:residential_agent)
    @com_agent_type = create(:commercial_agent)
    @company = create(:company)
    @user = create(:user, company: @company)
    @user2 = create(:user, company: @company)
    @manager = create(:user, company: @company)
  end

  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "bio should not be too long" do
    @user.bio = "a" * 501
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "mobile_phone_number validation should accept valid phone numbers" do
    valid_phones = %w[(555)555-5566 555.555.5555 5555555555 555-555-5555]
    valid_phones.each do |valid_phone|
      @user.mobile_phone_number = valid_phone
      assert @user.valid?, "#{valid_phone.inspect} should be valid"
    end
  end

  test "mobile_phone_number validation should reject invalid phone numbers" do
    valid_phones = %w[555-555-55-55 (555)555-555]
    valid_phones.each do |valid_phone|
      @user.mobile_phone_number = valid_phone
      assert_not @user.valid?, "#{valid_phone.inspect} should be invalid"
    end
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "archive sets the model to archived" do
    @user.archive
    assert_equal true, @user.reload.archived
  end

  test "find_unarchived does not return archived results" do
    @user.save
    assert_not_nil User.find_unarchived(@user.id)
    @user.archive
    assert_raises(ActiveRecord::RecordNotFound) { User.find_unarchived(@user.id) }
  end

  test "can get fname from name" do
    @user.name = "first last"
    assert @user.fname, "first"
  end

  test "search correct when valid user found" do
    @user.name = "raquel bujans"
    params = {}
    params[:name_email] = "bujans"
    results = User.search(params)
    assert results.length, 1
  end

  test "search correct when no valid user found" do
    @user.name = "raquel bujans"
    params = {}
    params[:name_email] = "blah"
    results = User.search(params)
    assert results.length, 0
  end

  # test the roles out
  test "update_roles sets residential agent as default" do
    @user.agent_types = nil
    @user.employee_title = EmployeeTitle.agent
    @user.update_roles
    assert @user.employee_title.name, EmployeeTitle.agent.name
    # everyone has residential by default
    assert @user.has_role? :residential
  end

  test "update_roles updates employee_title" do
    @user.agent_types = nil
    @user.employee_title = EmployeeTitle.closing_manager
    @user.update_roles
    assert @user.employee_title.name, EmployeeTitle.closing_manager.name
    assert @user.has_role? :closing_manager
    # everyone has residential by default
    assert @user.has_role? :residential
  end

  test "can get agent specialties" do
    @user.employee_title = EmployeeTitle.agent
    @user.agent_types = ['residential', 'commercial']
    @user.update_roles
    assert @user.has_role? :residential
    assert @user.agent_specialties[0], "residential"
    assert @user.agent_specialties[1], "commercial"
  end

  test "can get agent specialty id" do
    @user.employee_title = EmployeeTitle.agent
    @user.agent_types = ['residential', 'commercial']
    @user.update_roles
    assert @user.has_role? :residential
    assert @user.agent_specialties_as_indicies[0], 1
    assert @user.agent_specialties_as_indicies[1], 2
  end

  # # TODO test add_sanitized_role

  test "make manager works" do
    @manager.make_manager
    assert @manager.has_role? :manager
  end

  test "make company admin works" do
    @manager.make_company_admin
    assert @manager.has_role? :company_admin
  end

  test "is_manager? works" do
    @manager.make_manager
    assert @manager.has_role? :manager
    assert @manager.is_manager?
  end

  test "is_company_admin? works" do
    assert @manager.add_role :company_admin
    assert @manager.is_company_admin?
  end

  test "managers can add subordinates" do
    @manager.save
    @user.save
    @manager.make_manager
    @manager.add_subordinate(@user)
    assert @manager.subordinates.length, 1
    assert @user.manager, @manager
  end

  test "non-managers can't add subordinates" do
    exception = assert_raises(RuntimeError) { @manager.add_subordinate(@user) }
    assert @manager.subordinates.length, 0
  end

  test "is_management correctly identifies managers" do
    assert_not @manager.is_management?
    @manager.make_manager
    assert @manager.is_management?
  end

  test "managers can remove subordinates" do
    @manager.save
    @user.save
    @manager.make_manager
    @manager.add_subordinate(@user)
    assert @manager.subordinates.length, 1
    @manager.remove_subordinate(@user)
    assert @manager.subordinates.length, 0
    assert_not @user.manager
  end

  test "user can see their coworkers" do
    @user.save
    @user2.save
    @company.save
    assert @user.coworkers.length, 1
    assert @user.coworkers[0], @user2
  end 

  #test "super admin can see users from all companies" do
  #end 

  test "agent can't kick anyone" do
    assert_not @user.can_kick(@user2)
  end

  test "manager can kick a subordinate" do
    @manager.make_manager
    @manager.add_subordinate(@user)
    assert @manager.can_kick(@user)
  end

  test "manager can't kick someone who's not on their team" do
    @manager.make_manager
    assert_not @manager.can_kick(@user)
  end

  test "company admins can kick anyone" do
    assert @manager.add_role :company_admin
    assert @manager.is_company_admin?
    @manager.make_manager
    @manager.add_subordinate(@user)
    assert @manager.can_kick(@user)
  end

  test "kicking someone off a team works" do
    assert @manager.add_role :company_admin
    @manager.make_manager
    @manager.add_subordinate(@user)
    @user.kick
    assert_nil @user.manager
  end

  test "agents can't approve anyone" do
    assert_not @user.can_approve(@user2)
  end

  test "lower ran can't approve a higher rank" do
    @user.employee_title = EmployeeTitle.broker
    @user2.employee_title = EmployeeTitle.closing_manager
    @user.update_roles
    @user2.update_roles
    assert_not @user.can_approve(@user2)
  end

  test "agent can't manage another person's team" do
    assert_not @user.can_manage_team(@user2)
  end

  test "can't manage another's team if i am not a manager" do
    assert_not @manager.can_manage_team(@user)
  end

  test "can manage a team if i am their manager" do
    @manager.make_manager
    assert @manager.can_manage_team(@manager)
  end

  test "every user gets a unique auth token upon creation" do
    @user.save
    assert_not_nil @user.auth_token
    
    duplicate_user = @user.dup
    duplicate_user.save
    assert_not duplicate_user.valid?
  end

end