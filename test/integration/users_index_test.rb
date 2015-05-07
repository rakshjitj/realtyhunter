require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
    	assert_select 'a[href=?]', edit_user_path(user), text: "Edit"
    end
  end

  test "index shows only active users" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    User.paginate(page: 1).each do |user|
      assert user.activated
    end

  end
end