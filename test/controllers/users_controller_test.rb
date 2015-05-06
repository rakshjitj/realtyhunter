require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup do
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { fname: @user.fname, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { bio: @user.bio, 
                            email: Time.now.to_i.to_s + "_" + @user.email, 
                            fname: @user.fname, 
                            lname: @user.lname, 
                            password: "password", 
                            password_confirmation: "password" }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    log_in_as(@user)
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    log_in_as(@user)
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    log_in_as(@user)
    patch :update, id: @user, user: { bio: @user.bio, 
                                      email: @user.email, 
                                      fname: @user.fname, 
                                      lname: @user.lname, 
                                      password: "password", 
                                      password_confirmation: "password" }
    assert_redirected_to @user

  end

  test "should destroy user" do
    log_in_as(@user)
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get :edit, id: @user
    #assert flash.empty?
    assert_redirected_to users_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch :update, id: @user, user: { fname: @user.fname, email: @user.email }
    #assert flash.empty?
    assert_redirected_to users_url
  end
end
