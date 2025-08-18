class OfferItem < ApplicationRecord
  belongs_to :offer

  validates :name, :qty, :unit_price_cents, presence: true
  validates :qty, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  monetize :unit_price_cents

  # Allow setting unit_price as decimal value (will be converted to cents)
  def unit_price=(value)
    self.unit_price_cents = (value.to_f * 100).to_i if value.present?
  end

  def unit_price
    return 0 if unit_price_cents.nil?
    unit_price_cents / 100.0
  end

  def total_price_cents
    qty * unit_price_cents
  end

  def total_price
    Money.new(total_price_cents, offer.currency)
  end
end
