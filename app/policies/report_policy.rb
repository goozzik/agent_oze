class ReportPolicy < ApplicationPolicy
  def weekly?
    user.present?
  end

  def pipeline?
    user.present?
  end
end