require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @employee_title = employee_titles(:agent)
  end

  test "invalid signup information" do

    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "",
                               email: "user@invalid",
                               password:              "foo",
                               password_confirmation: "bar",
                               mobile_phone_number: '666-666-6666',
                               employee_title_id: 2 },
                        agent_title: @employee_title
    end
    assert_template 'users/new'
    # test that error msgs appear
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { name:  "Example User",
                               email: "user@example.com",
                               password:              "password",
                               password_confirmation: "password",
                               employee_title_id: 2,
                               company_id: 1,
                               office_id: 1,
                               mobile_phone_number: '666-666-6666',
                                },
                        agent_title: @employee_title
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)

    assert_not user.activated?
    assert_not user.approved?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    # still needs approval
    assert_not is_logged_in?
    # Valid approval token
    get edit_account_approval_path(user.approval_token, email: user.email)
    assert user.reload.activated?

    log_in_as(user)
    # follow_redirect!
    #assert_template 'users/show'
    assert is_logged_in?
  end

end