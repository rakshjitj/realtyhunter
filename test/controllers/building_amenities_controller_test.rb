require 'test_helper'

class BuildingAmenitiesControllerTest < ActionController::TestCase
  setup do
    @building_amenity = building_amenities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:building_amenities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create building_amenity" do
    assert_difference('BuildingAmenity.count') do
      post :create, building_amenity: { name: @building_amenity.name }
    end

    assert_redirected_to building_amenity_path(assigns(:building_amenity))
  end

  test "should show building_amenity" do
    get :show, id: @building_amenity
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @building_amenity
    assert_response :success
  end

  test "should update building_amenity" do
    patch :update, id: @building_amenity, building_amenity: { name: @building_amenity.name }
    assert_redirected_to building_amenity_path(assigns(:building_amenity))
  end

  test "should destroy building_amenity" do
    assert_difference('BuildingAmenity.count', -1) do
      delete :destroy, id: @building_amenity
    end

    assert_redirected_to building_amenities_path
  end
end
