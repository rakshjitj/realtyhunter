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

    # can do anything, but for his/her particular company only
    elsif user.has_role?(:company_admin) || user.has_role?(:manager)
      if user.has_role?(:company_admin)
        can :manage, User, :company_id => user.company_id
        can :manage, Company, :id => user.company.id
        can :manage, Office, :company_id => user.company.id
        can :manage, Landlord do |landlord|
          landlord.company_id == user.company_id
        end
      end

      if user.has_role?(:manager)
        can :read, Landlord do |landlord|
          landlord.company_id == user.company_id
        end
      end

      can :manage, Building, :company_id => user.company.id
      can :manage, ResidentialUnit do |residential_unit|
          residential_unit.building.company_id == user.company_id
        end
      can :manage, CommercialUnit do |commercial_unit|
        commercial_unit.building.company_id == user.company_id
      end


      
    else # regular users (agents, non-management)
      # can only see info for his/her particular company
      # can only manage his/her profile
      #can :read, :all
      if user.company_id
        can :read, User, :company_id => user.company_id
        can :read, Company, :id => user.company.id
        can :read, Office, :company_id => user.company.id
        can :read, Building, :company_id => user.company_id
        can :read, ResidentialUnit do |residential_unit|
          residential_unit.building.company_id == user.company_id
        end
        can :read, CommercialUnit do |commercial_unit|
          commercial_unit.building.company_id == user.company_id
        end
        
      end
      can :read, User
      can :manage, User, :id => user.id
    end

    
  end
end
