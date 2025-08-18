class Meeting < ApplicationRecord
  belongs_to :lead

  validates :scheduled_at, :location, presence: true

  scope :upcoming, -> { where('scheduled_at > ?', Time.current) }
  scope :past, -> { where('scheduled_at < ?', Time.current) }
end
