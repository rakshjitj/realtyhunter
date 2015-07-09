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
      can :manage, ResidentialUnit do |residential_unit|
        !residential_unit.building_id || user.is_management? || (residential_unit.building.company_id == user.company_id && user.handles_residential?)
        end
      can :manage, CommercialUnit do |commercial_unit|
        !commercial_unit.building_id || user.is_management? || (commercial_unit.building.company_id == user.company_id && user.handles_commercial?)
      end
    
    elsif user.has_role?(:external_vendor)
      cannot :read, :all
      can :manage, User, :id => user.id

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
