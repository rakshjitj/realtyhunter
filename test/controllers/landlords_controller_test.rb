require 'test_helper'

class LandlordsControllerTest < ActionController::TestCase
  setup do
    @landlord = landlords(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:landlords)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create landlord" do
    assert_difference('Landlord.count') do
      post :create, landlord: { city: @landlord.city, code: @landlord.code, email: @landlord.email, fax: @landlord.fax, listing_agent_percentage: @landlord.listing_agent_percentage, management_info: @landlord.management_info, mobile: @landlord.mobile, months_required: @landlord.months_required, name: @landlord.name, notes: @landlord.notes, pet_policy: @landlord.pet_policy, phone: @landlord.phone, state: @landlord.state, street_address: @landlord.street_address, website: @landlord.website, zipcode: @landlord.zipcode }
    end

    assert_redirected_to landlord_path(assigns(:landlord))
  end

  test "should show landlord" do
    get :show, id: @landlord
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @landlord
    assert_response :success
  end

  test "should update landlord" do
    patch :update, id: @landlord, landlord: { city: @landlord.city, code: @landlord.code, email: @landlord.email, fax: @landlord.fax, listing_agent_percentage: @landlord.listing_agent_percentage, management_info: @landlord.management_info, mobile: @landlord.mobile, months_required: @landlord.months_required, name: @landlord.name, notes: @landlord.notes, pet_policy: @landlord.pet_policy, phone: @landlord.phone, state: @landlord.state, street_address: @landlord.street_address, website: @landlord.website, zipcode: @landlord.zipcode }
    assert_redirected_to landlord_path(assigns(:landlord))
  end

  test "should destroy landlord" do
    assert_difference('Landlord.count', -1) do
      delete :destroy, id: @landlord
    end

    assert_redirected_to landlords_path
  end
end
