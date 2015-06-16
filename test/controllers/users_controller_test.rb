require 'factory_girl_rails'
include FactoryGirl::Syntax::Methods
require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup do
    @user = create(:user)
    @other_user = create(:user)
  end

  test "should redirect index when not logged in" do
    get :index
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_redirected_to login_url
  end

  test "should show user" do
    log_in_as(@user)
    get :show, id: @user
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get :edit, id: @user
    #assert flash.empty?
    assert_redirected_to users_url
  end

  test "should get edit" do
    log_in_as(@user)
    get :edit, id: @user
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { bio: @user.bio, 
                            email: Time.now.to_i.to_s + "_" + @user.email, 
                            name: @user.name, 
                            password: "password", 
                            password_confirmation: "password" }
    end

    assert_redirected_to root_url #user_path(assigns(:user))
  end

  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_not is_logged_in?
    # TODO: Why doesn't this work?
    #assert_redirected_to login_url
  end

  test "should update user" do
    log_in_as(@user)
    patch :update, id: @user, user: { bio: @user.bio, 
                                      email: @user.email, 
                                      name: @user.name, 
                                      password: "password", 
                                      password_confirmation: "password" }
    assert_redirected_to @user
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    #assert flash.empty?
    assert_redirected_to users_url
  end


  test "should destroy user" do
    log_in_as(@user)
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end

  # test "should upload image" do
  #   log_in_as(@user)
  #   patch :upload_image, id: @user, 
  #   user: { 
  #     user_avatar: "test.gif"
  #   }
  #   assert_redirected_to @user
  #   puts "***** #{@user.inspect}"
  # end

  # test "should upload image from remote url" do
  #   log_in_as(@user)
  #   patch :upload_image, id: @user, 
  #   user: { 
  #     remote_avatar: "https://c402277.ssl.cf1.rackcdn.com/photos/144/images/hero_small/Giant_Panda_Hero_image_(c)_Michel_Gunther_WWF_Canon.jpg?1345515244"
  #   }
  #   assert_redirected_to @user
  #   puts "***** #{@user.inspect}"
  # end

  # test "should remove image from remote url" do
  #   # upload image first
  #   log_in_as(@user)
  #   patch :upload_image, id: @user, 
  #   user: { 
  #     user_avatar: "test.gif"
  #   }
  #   assert_redirected_to @user

  #   # now remove
  #   patch :upload_image, id: @user, 
  #   user: { 
  #     remove_avatar: true
  #   }
  #   assert_redirected_to @user
  # end

  # test only admin can edit other people's roles
end