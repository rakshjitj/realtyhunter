class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    # global super admin can control everything
    if user.has_role? :super_admin
      # can do anything
      can :manage, :all

    # company admins can do anything, but for his/her particular company only
    # managers/data entry can do most things
    elsif user.has_role?(:company_admin) || user.has_role?(:manager) || user.has_role?(:data_entry)
      if user.has_role?(:company_admin)
        can :manage, User, :company_id => user.company_id
        can :manage, Company, :id => user.company.id
        can :manage, Office, :company_id => user.company.id
        can :manage, Landlord do |landlord|
          !landlord.company_id || landlord.company_id == user.company_id
        end
      elsif user.has_role?(:data_entry)
        can :read, User, :company_id => user.company_id
        can :read, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id
        can :manage, Landlord do |landlord|
          !landlord.company_id || landlord.company_id == user.company_id
        end
      elsif user.has_role?(:manager)
        can :read, User, :company_id => user.company_id
        can :manage, User, :id => user.id
        can :read, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id
        can :read, Landlord do |landlord|
          landlord.company_id == user.company_id
        end
      end

      can :manage, Building, :company_id => user.company.id
      can :manage, ResidentialListing do |residential_listing|
        !residential_listing.unit || user.is_management? || (residential_listing.building.company_id == user.company_id && user.handles_residential?)
      end
      can :manage, CommercialListing do |commercial_listing|
        !commercial_listing.unit || user.is_management? || (commercial_listing.building.company_id == user.company_id && user.handles_commercial?)
      end
    
    elsif user.has_role?(:external_vendor)
      cannot :read, :all
      can :manage, User, :id => user.id

    else # regular users (agents, non-management)
      # can only see info for his/her particular company
      # can only manage his/her profile
      # can't view landlords
      if user.company_id
        alias_action :managers, :employees, :agents, :to => :view_staff

        can :read, Company, :id => user.company.id
        can :view_staff, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id
        can :view_staff, Office, :id => user.company.id

        can :read, Building, :company_id => user.company_id
        can :filter, Building, :company_id => user.company_id
        
        can :read, ResidentialListing do |residential_listing|
          residential_listing.unit.building.company_id == user.company_id && user.handles_residential?
        end
        can :filter, ResidentialListing, :company_id => user.company_id

        can :read, CommercialListing do |commercial_listing|
          commercial_listing.unit.building.company_id == user.company_id && user.handles_commercial?
        end
        can :filter, CommercialListing, :company_id => user.company_id

        can :read, User, :company_id => user.company_id

      end
      can :manage, User, :id => user.id
    end
    
  end
end
