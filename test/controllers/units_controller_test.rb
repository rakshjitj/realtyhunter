require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class UnitsControllerTest < ActionController::TestCase
  setup do
    @unit = create(:unit)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create unit" do
    assert_difference('Unit.count') do
      post :create, unit: { baths: @unit.baths, beds: @unit.beds, rent: @unit.rent, string: @unit.string, unit: @unit.unit }
    end

    assert_redirected_to unit_path(assigns(:unit))
  end

  test "should show unit" do
    get :show, id: @unit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @unit
    assert_response :success
  end

  test "should update unit" do
    patch :update, id: @unit, unit: { baths: @unit.baths, beds: @unit.beds, rent: @unit.rent, string: @unit.string, unit: @unit.unit }
    assert_redirected_to unit_path(assigns(:unit))
  end

  test "should destroy unit" do
    assert_difference('Unit.count', -1) do
      delete :destroy, id: @unit
    end

    assert_redirected_to units_path
  end
end
