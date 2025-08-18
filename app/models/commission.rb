class Commission < ApplicationRecord
  belongs_to :lead

  validates :amount_cents, :booked_at, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }

  monetize :amount_cents
end
