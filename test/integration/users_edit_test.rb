require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as @user
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { fname:  "",
    								lname:  "",
                                    bio: "",
                                    email: "foo@invalid",
                                    password:              "foo",
                                    password_confirmation: "bar" }
    assert_template 'users/edit'
  end

  test "successful edit" do
    log_in_as @user
    get edit_user_path(@user)
    assert_template 'users/edit'
    fname  = "Foo"
    lname = "Bar"
    email = "foo@bar.com"
    bio = "afsdfasdfsad"
    patch user_path(@user), user: { fname: fname,
    	 						    lname: lname,
                                    email: email,
                                    bio: bio,
                                    password:              "",
                                    password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.fname,  fname
    assert_equal @user.lname,  lname
    assert_equal @user.email, email
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    fname  = "Foo"
    lname = "Bar"
    email = "foo@bar.com"
    patch user_path(@user), user: { fname: fname,
                                    lname: lname,
                                    email: email,
                                    password:              "foobar",
                                    password_confirmation: "foobar" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.fname, fname
    assert_equal @user.lname, lname
    assert_equal @user.email, email
  end
end
