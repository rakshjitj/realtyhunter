class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    alias_action :managers, :employees, :agents, :to => :view_staff

    # global super admin can control everything
    if user.has_role? :super_admin
      # can do anything
      can :manage, :all

    # company admins can do anything, but for his/her particular company only
    # managers/data entry can do most things
    elsif user.has_role?(:company_admin) || user.has_role?(:manager) || user.has_role?(:data_entry) || user.has_role?(:closing_manager)

      if user.has_role?(:company_admin) || user.has_role?(:closing_manager)
        can :manage, User, :company_id => user.company_id
        can :manage, Company, :id => user.company.id
        can :manage, Office, :company_id => user.company.id
        can :manage, Landlord do |landlord|
          !landlord.company_id || landlord.company_id == user.company_id
        end
      elsif user.has_role?(:data_entry)

        can :read, Company, :id => user.company.id
        can :view_staff, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id
        can :view_staff, Office, :id => user.company.id

        can :read, Building, :company_id => user.company_id
        can :filter, Building, :company_id => user.company_id

        can :read, User, :company_id => user.company_id
        can :manage, Landlord do |landlord|
          !landlord.company_id || landlord.company_id == user.company_id
        end
      

      elsif user.has_role?(:manager)
        can :read, User, :company_id => user.company_id
        can :manage, User, :id => user.id
        can :view_staff, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id
        can :read, Landlord do |landlord|
          landlord.company_id == user.company_id
        end
      end

      can :manage, Neighborhood
      can :manage, BuildingAmenity, :company_id => user.company.id
      can :manage, ResidentialAmenity, :company_id => user.company.id
      can :manage, Utility, :company_id => user.company.id
      can :manage, Building, :company_id => user.company.id
      can :manage, ResidentialListing do |residential_listing|
        !residential_listing.unit || user.is_management? || (residential_listing.unit.building.company_id == user.company_id && user.handles_residential?)
      end
      can :manage, CommercialListing do |commercial_listing|
        !commercial_listing.unit || user.is_management? || (commercial_listing.unit.building.company_id == user.company_id && user.handles_commercial?)
      end

      # everyone can filter, send error reports
      can [:filter, :neighborhoods_modal, :features_modal, :print_list], [ResidentialListing, CommercialListing]
      can [:inaccuracy_modal, :send_inaccuracy, :print_modal, :print_public, :print_private], [ResidentialListing, CommercialListing]
      can [:autocomplete_building_formatted_street_address], [ResidentialListing, CommercialListing, Building]
      can [:autocomplete_landlord_code], [ResidentialListing, Landlord]
      can [:autocomplete_user_name, :filter, :filter_listings, :coworkers, :subordinates], [User]

    
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

        can :read, Building, :company_id => user.company_id
        can :filter, Building, :company_id => user.company_id
        
        can :read, ResidentialListing do |residential_listing|
          residential_listing.unit.building.company_id == user.company_id && user.handles_residential?
        end
        
        # everyone can filter, send error reports
        can [:filter, :neighborhoods_modal, :features_modal, :print_list], [ResidentialListing, CommercialListing]
        can [:inaccuracy_modal, :send_inaccuracy, :print_modal, :print_public, :print_private], [ResidentialListing, CommercialListing]
        can [:autocomplete_building_formatted_street_address], [ResidentialListing, CommercialListing, Building]
        can [:autocomplete_landlord_code], [ResidentialListing, Landlord]

        can :read, CommercialListing do |commercial_listing|
          commercial_listing.unit.building.company_id == user.company_id && user.handles_commercial?
        end
        can :filter, CommercialListing, :company_id => user.company_id

        can :read, User, :company_id => user.company_id
      
        can :read, :Neighborhood
        can :read, BuildingAmenity, :company_id => user.company.id
        can :read, ResidentialAmenity, :company_id => user.company.id
        can :read, Utility, :company_id => user.company.id
      end
      can :manage, User, :id => user.id
      can [:autocomplete_user_name], User
    end
    
  end
end
