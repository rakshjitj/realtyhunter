class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    #if user.has_role? :api_only
      # TODO
    # global super admin can control everything
    if user.has_role? :super_admin
      # can do anything
      can :manage, :all

    # company admins can do anything, but for his/her particular company only
    # managers can do most things
    elsif user.has_role?(:company_admin) || user.has_role?(:manager)
      if user.has_role?(:company_admin)
        can :manage, User, :company_id => user.company_id
        can :manage, Company, :id => user.company.id
        can :manage, Office, :company_id => user.company.id
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
      can :manage, ResidentialUnit do |residential_unit|
          !residential_unit.building_id || residential_unit.building.company_id == user.company_id && user.handles_residential?
        end
      can :manage, CommercialUnit do |commercial_unit|
        !commercial_unit.building_id || commercial_unit.building.company_id == user.company_id && user.handles_commercial?
      end
      
    else # regular users (agents, non-management)
      # can only see info for his/her particular company
      # can only manage his/her profile
      # can't view landlords
      if user.company_id
        alias_action :managers, :employees, :to => :view_staff

        can :read, Company, :id => user.company.id
        can :view_staff, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id

        can :read, Building, :company_id => user.company_id
        can :read, ResidentialUnit do |residential_unit|
          residential_unit.building.company_id == user.company_id && user.handles_residential?
        end
        can :read, CommercialUnit do |commercial_unit|
          commercial_unit.building.company_id == user.company_id && user.handles_commercial?
        end

        can :read, User, :company_id => user.company_id

      end
      can :manage, User, :id => user.id
    end
    
  end
end
