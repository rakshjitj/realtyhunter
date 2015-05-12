require 'test_helper'

class CompaniesEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @company = companies(:one)
  end

  test "unsuccessful edit" do
    log_in_as @user
    get edit_company_path(@company)
    assert_template 'companies/edit'
    patch company_path(@company), company: { name:  "" }
    assert_template 'companies/edit'
  end

  test "successful edit" do
    log_in_as @user
    get edit_company_path(@company)
    assert_template 'companies/edit'
    name  = "Foo Bar"
    patch company_path(@company), company: { name: name }
    assert_not flash.empty?
    assert_redirected_to @company
    @company.reload
    assert_equal @company.name,  name
  end

  test "successful edit with friendly forwarding" do
    get edit_company_path(@company)
    log_in_as @user
    assert_redirected_to edit_company_path(@company)
    name  = "Foo Bar"
    patch company_path(@company), company: { name: name }
    assert_not flash.empty?
    assert_redirected_to @company
    @company.reload
    assert_equal @company.name, name
  end
end
