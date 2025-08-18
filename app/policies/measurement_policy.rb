class MeasurementPolicy < ApplicationPolicy
  def new?
    user.present?
  end

  def create?
    user.present?
  end

  def show?
    user.present? && (user.admin? || record.lead.user == user || record.measured_by == user)
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def destroy?
    user.present? && (user.admin? || record.measured_by == user)
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:lead).where(leads: { user: user })
      end
    end
  end
end