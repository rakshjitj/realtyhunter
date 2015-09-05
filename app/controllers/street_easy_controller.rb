class StreetEasyController < ApplicationController
  skip_authorize_resource
  skip_before_action :logged_in_user
  include StreetEasyInterface
  
  def show
    set_listings
    respond_to do |format|
      format.rss { render :layout => false }
    end
  end

  def set_listings
    @company = Company.find(streeteasy_params[:id])
    if @company
      @listings = pull_data(@company.id, streeteasy_params)
      @pet_policies = Unit.get_pet_policies(@listings)
      @residential_amenities = ResidentialListing.get_amenities(@listings)
      @building_amenities = Building.get_amenities(@listings)
      @images = Unit.get_all_images(@listings)

      @primary_agents, @agent_images = Unit.get_primary_agents_and_images(@listings)
    end
  end

  def streeteasy_params
    params.permit(:format, :id)
  end
end