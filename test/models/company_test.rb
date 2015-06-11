require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  def setup
    @company = companies(:one)
  end

  test "should be valid" do
    assert @company.valid?
  end

  test "name should be present" do
    @company.name = "     "
    assert_not @company.valid?
  end

  test "name should be unique" do
    duplicate_company = @company.dup
    duplicate_company.name = @company.name.upcase
    @company.save
    assert_not duplicate_company.valid?
  end

  test "archive sets the model to archived" do
    @company.archive
    assert_equal true, @company.reload.archived
  end

  test "find_unarchived does not return archived results" do
    assert_not_nil Company.find_unarchived(@company.id)
    @company.archive
    assert_raises(ActiveRecord::RecordNotFound) { Company.find_unarchived(@company.id) }
  end

  test "admins returns only admin users" do
    @user = users(:michael)
    @user2 = users(:lana)
    @user.make_company_admin
    assert 1, @company.admins.count
  end

  test "managers returns only manager users" do
    @user = users(:michael)
    @user2 = users(:lana)
    @user.make_manager
    assert 1, @company.managers.count
  end

  # TODO: update_agent_types, update_employee_titles


end
