class Ability
  include CanCan::Ability

  def common_permissions(user)
    # everyone can filter, send error reports
    can :filter, Building, :company_id => user.company_id
    can [:filter, :neighborhoods_modal, :features_modal, :print_list], [ResidentialListing, CommercialListing]
    can [:inaccuracy_modal, :send_inaccuracy, :print_modal, :print_public, :print_private], [ResidentialListing, CommercialListing]
    can [:autocomplete_building_formatted_street_address], [ResidentialListing, CommercialListing, Building]
    can [:autocomplete_landlord_code], [ResidentialListing, Landlord]
    can [:autocomplete_user_name, :filter, :filter_listings, :coworkers, :subordinates], [User]

    can [:send_listings], [ResidentialListing, CommercialListing]
  end

  def posting_permissions(user)
    can :manage, Building, :company_id => user.company.id

    can :manage, ResidentialListing do |residential_listing|
      !residential_listing.unit || user.is_management? || (residential_listing.unit.building.company_id == user.company_id && user.handles_residential?)
    end
    can :manage, SalesListing do |sales_listing|
      !sales_listing.unit || user.is_management? || (sales_listing.unit.building.company_id == user.company_id && user.handles_sales?)
    end
    can :manage, CommercialListing do |commercial_listing|
      !commercial_listing.unit || user.is_management? || (commercial_listing.unit.building.company_id == user.company_id && user.handles_commercial?)
    end
  end

  # Nir, Michelle, Shawn, Dani, Cheryl, Ashleigh, me
  def roomsharing_permissions(user)
    if user.has_role? :roomsharing
      can :manage, Roommate
      can :manage, WufooContactUsForm
      can :manage, WufooListingsForm
      can :manage, WufooPartnerForm
      can :manage, RoomsharingApplication
    else
      can [:new, :create, :show], Roommate
    end
  end

  # I seperated out these 2 groups so you can easily compare them side by side
  # managers v agents

  def common_managerial_permissions(user)
      #can :manage, Roommate, :company_id => user.company.id
      can :manage, Neighborhood
      can :manage, BuildingAmenity, :company_id => user.company.id
      can :manage, ResidentialAmenity, :company_id => user.company.id
      can :manage, Utility, :company_id => user.company.id
      posting_permissions(user)
      can :manage, UserWaterfall
  end

  def agent_permissions(user)
    #can [:new, :create, ], Roommate, :user_id => user.id
    #cannot :index, Roommate, :company_id => user.company.id
    can :read, :Neighborhood
    can :read, BuildingAmenity, company_id: user.company.id
    can :read, ResidentialAmenity, company_id: user.company.id
    can :read, Utility, company_id: user.company.id
    can :read, Building, company_id: user.company_id

    can :read, ResidentialListing do |residential_listing|
      residential_listing.unit.building.company_id == user.company_id #&& user.handles_residential?
    end
    can :read, SalesListing do |sales_listing|
        !sales_listing.unit || user.is_management? || (sales_listing.unit.building.company_id == user.company_id) #&& user.handles_residential?)
      end
    can :read, CommercialListing do |commercial_listing|
      commercial_listing.unit.building.company_id == user.company_id #&& user.handles_commercial?
    end
    can :filter, CommercialListing, company_id: user.company_id

    can :show, UserWaterfall, parent_agent_id: user.id
  end

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    alias_action :managers, :employees, :agents, :to => :view_staff

    # global super admin can control everything
    if user.has_role? :super_admin
      # can do anything
      can :manage, :all

    # company admins can do anything, but for his/her particular company only
    # managers/data entry can do most things
    elsif user.has_role?(:company_admin) || user.has_role?(:manager) || 
      user.has_role?(:data_entry) || user.has_role?(:closing_manager) ||
      user.has_role?(:listings_manager)

      if user.has_role?(:company_admin) || user.has_role?(:closing_manager)
        # managers/admins of any kind can manage user accounts
        can :manage, User, :company_id => user.company_id
        can :manage, Company, :id => user.company.id
        can :manage, Office, :company_id => user.company.id
        can :manage, Landlord do |landlord|
          !landlord.company_id || landlord.company_id == user.company_id
        end

      # user can enter in all kinds of data
      # if labelled "posting admin", then this is an agent who has been
      # entrusted with managing listings. They should still show up labelled as 
      # an "agent" on the rest of the site
      elsif user.has_role?(:data_entry) || user.has_role?(:listings_manager)

        can :read, Company, :id => user.company.id
        can :view_staff, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id
        can :view_staff, Office, :id => user.company.id

        can :read, Building, :company_id => user.company_id
        can :filter, Building, :company_id => user.company_id

        # should only be able to edit their own user profile
        can :read, User, :company_id => user.company_id
        can :manage, User, :id => user.id

        can :manage, Landlord do |landlord|
          !landlord.company_id || landlord.company_id == user.company_id
        end

      elsif user.has_role?(:manager)
        # managers/admins of any kind can manage user accounts
        can :manage, User, :company_id => user.company_id
        can :read, User, :company_id => user.company_id
        can :view_staff, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id
        can :read, Landlord do |landlord|
          landlord.company_id == user.company_id
        end
      end

      common_permissions(user)
      common_managerial_permissions(user)
      roomsharing_permissions(user)

    elsif user.has_role?(:external_vendor)
      cannot :read, :all
      can :manage, User, :id => user.id

    else # regular users (agents, non-management)
      # can only see info for his/her particular company
      # can only manage his/her profile
      # can't view landlords
      if user.company_id

        can :read, Company, :id => user.company.id
        can :view_staff, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id
        can :view_staff, Office, :id => user.company.id

        common_permissions(user)
        agent_permissions(user)

        can :read, User, :company_id => user.company_id
      end
      
      can :manage, User, :id => user.id
      roomsharing_permissions(user)
    end
    
  end
end
