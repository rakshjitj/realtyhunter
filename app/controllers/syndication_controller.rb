  class SyndicationController < ApplicationController
  skip_authorize_resource
  skip_before_action :logged_in_user
  protect_from_forgery with: :null_session
  include SyndicationInterface

  def naked_apts
    set_listings
  end

  def streeteasy
    set_listings
  end

  def trulia
    set_listings
  end

  def set_listings
    @company = Company.find(syndication_params[:id])
    if @company
      if syndication_params[:action] == 'naked_apts'
        @listings = naked_apts_listings(@company.id, syndication_params)
      elsif syndication_params[:action] == 'streeteasy'
        @listings = streeteasy_listings(@company.id, syndication_params)
      elsif syndication_params[:action] == 'trulia'
        @listings = trulia_listings(@company.id, syndication_params)
      end

      @pet_policies = Building.get_pet_policies(@listings)
      @residential_amenities = ResidentialListing.get_amenities(@listings)
      @building_amenities = Building.get_amenities(@listings)
      @images = Unit.get_all_images(@listings)
      @utilities = Building.get_utilities(@listings)

      # can you cache a function like this?
      @primary_agents, @agent_images = Unit.get_primary_agents_and_images(@listings)

      respond_to do |format|
        format.rss { render layout: false }
      end
    end
  end

  def syndication_params
    params.permit(:format, :id, :network, :action)
  end
end
