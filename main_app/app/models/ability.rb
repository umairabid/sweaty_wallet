# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # Guest user
    if user.id.nil?
      can :manage, :session
      can :manage, :registration
      can :manage, :password
      can :manage, :confirmation
      cannot :destroy, :session
    end

    if user.id
      can :manage, :dashboard
      can :manage, :account
      can :manage, :transaction
      can :manage, :category
      can :manage, :connector
      can :manage, :transaction_rule
      can :manage, :confirmation
      can :destroy, :session
      can :edit, :registration
      can :update, :registration
      can :manage, :net_worth
    end
  end
end
