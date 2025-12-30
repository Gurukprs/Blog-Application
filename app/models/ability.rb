# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Users can read all posts and comments
    can :read, Post
    can :read, Comment

    # Users can create posts and comments
    can :create, Post
    can :create, Comment

    # Users can only manage (update, destroy) their own posts
    can [:update, :destroy], Post, user_id: user.id

    # Users can only manage (update, destroy) their own comments
    can [:update, :destroy], Comment, user_id: user.id
  end
end
