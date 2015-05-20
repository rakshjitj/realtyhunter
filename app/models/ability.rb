class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :super_admin
      # can do anything
      can :manage, :all
      # can only see info for his/her particular company
      # can do anything, but only for his/her particular company
    elsif user.has_role? :company_admin
      can :manage, Company, :id => user.company.id
      can :manage, Office, :company_id => user.company.id
      can :manage, User, :company_id => user.company_id
      can :manage, Building
      can :manage, ResidentialUnit
      #can :manage, Landlord
    else
      # can only see info for his/her particular company
      # can only manage his/her profile
      can :read, Office, :company_id => user.company.id
      can :read, User, :company_id => user.company_id
      can :manage, User, :id => user.id
      can :read, :all
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
