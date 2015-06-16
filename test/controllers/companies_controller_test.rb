require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase

  setup do
    @company = create(:company)
    @user = create(:user)
  end

  test "should redirect index when not logged in" do
    get :index
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_redirected_to login_url
  end

  test "should get index" do
    log_in_as(@user)
    get :index
    assert_response :success
    assert_not_nil assigns(:companies)
  end

  test "should redirect new when not logged in" do
    get :new
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_redirected_to login_url
  end

  test "should get new" do
    log_in_as(@user)
    get :new
    assert_response :success
  end

  test "should redirect create when not logged in" do
    get :create
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_redirected_to login_url
  end

  test "should create company" do
    log_in_as(@user)
    assert_difference('Company.count') do
      post :create, company: { name: "Nooklyn" }
    end

    assert_redirected_to company_path(assigns(:company))
  end

  test "should redirect show when not logged in" do
    get :show, id: @company
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_redirected_to login_url
  end

  test "should show company" do
    log_in_as(@user)
    get :show, id: @company
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @company
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_redirected_to login_url
  end

  test "should get edit" do
    log_in_as(@user)
    get :edit, id: @company
    assert_response :success
  end

  test "should redirect update when not logged in" do
    patch :update, id: @company, company: { name: "three" }
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_redirected_to login_url
  end

  test "should update company" do
    log_in_as(@user)
    patch :update, id: @company, company: { name: 'updated name'}
    assert_redirected_to company_path(assigns(:company))
  end

  test "should redirect destroy when not logged in" do
    delete :destroy, id: @company, company: { }
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_redirected_to login_url
  end

  test "should destroy company" do
    log_in_as(@user)
    assert_difference('Company.count', -1) do
      delete :destroy, id: @company
    end

    assert_redirected_to companies_path
  end
end
