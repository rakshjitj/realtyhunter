class StaticPagesController < ApplicationController
	skip_authorize_resource
	skip_before_action :logged_in_user, only: [:home, :help]

  def home
  	if current_user
	  	if current_user.is_external_vendor?
	      redirect_to current_user
	    else
	    #elsif current_user.handles_residential?
	      redirect_to residential_listings_path
	    #elsif current_user.handles_commercial?
	    #  redirect_to commercial_listings_path
	    #else
	    #  redirect_to current_user
	    end
	  end
  end

  def help
  end
end
