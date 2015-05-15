class StaticPagesController < ApplicationController
	skip_before_action :logged_in_user, only: [:home, :help]

  def home
  end

  def help
  end
end
