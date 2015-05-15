require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["admin-no-reply@myspacenyc.com"], mail.from
    assert_match user.fname,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end

  test "password_reset" do
    user = users(:michael)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "Password reset", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["admin-no-reply@myspacenyc.com"], mail.from
    assert_match user.reset_token,        mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end

  test "account_approval_needed" do
    company = companies(:one)
    employee_title = employee_titles(:company_admin)
    user = users(:michael)
    admin = users(:lana)
    user.employee_title = employee_title
    admin.employee_title = employee_title
    company.users << [admin, user]
    admin.update_roles
    user.approval_token = User.new_token

    mail = UserMailer.account_approval_needed(user, company)
    assert_equal "Account approval needed", mail.subject
    assert_equal company.admins.map(&:email), mail.to
    assert_equal ["admin-no-reply@myspacenyc.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.email,               mail.body.encoded
    assert_match user.approval_token,   mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end

  test "account_approval_done" do
    company = companies(:one)
    user = users(:michael)
    company.users << user

    mail = UserMailer.account_approval_done(user)
    assert_equal "Account approved", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["admin-no-reply@myspacenyc.com"], mail.from
    assert_match user.company.name, mail.body.encoded
  end

end
