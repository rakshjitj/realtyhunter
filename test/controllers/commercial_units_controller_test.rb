require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class CommercialUnitsControllerTest < ActionController::TestCase
  setup do
    @commercial_unit = create(:commercial_unit)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:commercial_units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create commercial_unit" do
    assert_difference('CommercialUnit.count') do
      post :create, commercial_unit: {  }
    end

    assert_redirected_to commercial_unit_path(assigns(:commercial_unit))
  end

  test "should show commercial_unit" do
    get :show, id: @commercial_unit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @commercial_unit
    assert_response :success
  end

  test "should update commercial_unit" do
    patch :update, id: @commercial_unit, commercial_unit: {  }
    assert_redirected_to commercial_unit_path(assigns(:commercial_unit))
  end

  test "should destroy commercial_unit" do
    assert_difference('CommercialUnit.count', -1) do
      delete :destroy, id: @commercial_unit
    end

    assert_redirected_to commercial_units_path
  end
end
