class UserPolicy < ApplicationPolicy
  def show?
    agent_and_belongs_to_record_organisation?
  end

  def new?
    create?
  end

  def create?
    user_and_is_record_or_is_parent? || agent_and_belongs_to_record_organisation?
  end

  def link_to_organisation?
    @user_or_agent.agent?
  end

  def invite?
    @user_or_agent.agent?
  end

  def update?
    user_and_is_record_or_is_parent? || agent_and_belongs_to_record_organisation?
  end

  def edit?
    update?
  end

  def destroy?
    user_and_is_record_or_is_parent? || agent_and_belongs_to_record_organisation?
  end

  private

  def user_and_is_record_or_is_parent?
    @user_or_agent.user? && [@record.parent_id, @record.id].include?(@user_or_agent.id)
  end

  class Scope
    attr_reader :user_or_agent, :scope

    def initialize(user_or_agent, scope)
      @user_or_agent = user_or_agent
      @scope = scope
    end

    def resolve
      if @user_or_agent.agent?
        scope.all
      else
        scope.where(parent_id: @user_or_agent.id)
      end
    end
  end
end
