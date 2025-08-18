class ContractPolicy < ApplicationPolicy
  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def destroy?
    user.admin?
  end

  def download_pdf?
    user.present?
  end

  def send_contract?
    user.present?
  end
end