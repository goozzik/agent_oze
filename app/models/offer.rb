class Offer < ApplicationRecord
  belongs_to :lead
  has_many :offer_items, dependent: :destroy
  has_one_attached :pdf

  enum :status, { draft: 0, sent: 1, accepted: 2, rejected: 3 }
  enum :decision_status, { 
    pending_decision: 0, 
    customer_yes: 1, 
    customer_no: 2, 
    customer_maybe: 3,
    followup_scheduled: 4
  }

  validates :number, presence: true, uniqueness: true
  validates :currency, presence: true

  before_validation :generate_number, on: :create
  before_validation :calculate_total
  after_save :update_total

  accepts_nested_attributes_for :offer_items, allow_destroy: true, reject_if: :all_blank

  monetize :total_cents, with_model_currency: :currency

  # Decision handling methods
  def decision_made?
    decision_made_at.present?
  end

  def awaiting_decision?
    sent? && !decision_made?
  end

  def can_make_decision?
    sent? && !decision_made?
  end

  def decision_deadline
    return nil unless sent_at
    sent_at + 14.days # 2 weeks to decide
  end

  def decision_overdue?
    return false unless decision_deadline
    Date.current > decision_deadline.to_date
  end

  def days_until_decision_deadline
    return nil unless decision_deadline
    (decision_deadline.to_date - Date.current).to_i
  end

  private

  def generate_number
    return if number.present?
    self.number = "OFF-#{Date.current.strftime('%Y%m')}-#{sprintf('%04d', Offer.count + 1)}"
  end

  def calculate_total
    total = offer_items.sum { |item| item.qty.to_i * (item.unit_price_cents || 0) }
    self.total_cents = total
  end

  def update_total
    calculate_total
    update_column(:total_cents, total_cents) if persisted? && changed?
  end
end
