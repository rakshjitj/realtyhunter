require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  # TODO
  # test out all routes based on permissions?


  # TESTS for regular agent user
  test "coworkers page is accessible" do
    get coworkers_user_path(@user)
    #assert_redirected_to users_path
    assert_redirected_to 'users/coworkers'
    #assert_select 'div.pagination'
    #User.paginate(page: 1).each do |user|
   # 	assert_select 'a[href=?]', edit_user_path(user), text: "Edit"
   # end
  end

  # test "index shows only active users" do
  #   get users_path
  #   assert_template 'users/index'
  #   #User.paginate(page: 1).each do |user|
  #   #  assert user.activated
  #   #end
  # end
end