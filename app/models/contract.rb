class Contract < ApplicationRecord
  belongs_to :lead
  has_one_attached :pdf

  validates :number, presence: true, uniqueness: true
  validates :total_amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :payment_terms, presence: true
  validates :delivery_date, presence: true

  before_validation :generate_number, on: :create

  monetize :total_amount_cents

  def sent?
    sent_at.present?
  end

  private

  def generate_number
    return if number.present?
    self.number = "CON-#{Date.current.strftime('%Y%m')}-#{sprintf('%04d', Contract.count + 1)}"
  end
end
