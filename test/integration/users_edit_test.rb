require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    post login_path, session: { email: @user.email, password: 'password' }
    follow_redirect!
  end

  test "unsuccessful edit" do
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
end
