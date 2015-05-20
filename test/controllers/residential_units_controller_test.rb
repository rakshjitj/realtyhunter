require 'test_helper'

class ResidentialUnitsControllerTest < ActionController::TestCase
  setup do
    @residential_unit = residential_units(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:residential_units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create residential_unit" do
    assert_difference('ResidentialUnit.count') do
      post :create, residential_unit: {  }
    end

    assert_redirected_to residential_unit_path(assigns(:residential_unit))
  end

  test "should show residential_unit" do
    get :show, id: @residential_unit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @residential_unit
    assert_response :success
  end

  test "should update residential_unit" do
    patch :update, id: @residential_unit, residential_unit: {  }
    assert_redirected_to residential_unit_path(assigns(:residential_unit))
  end

  test "should destroy residential_unit" do
    assert_difference('ResidentialUnit.count', -1) do
      delete :destroy, id: @residential_unit
    end

    assert_redirected_to residential_units_path
  end
end
