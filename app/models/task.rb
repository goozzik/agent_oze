class Task < ApplicationRecord
  belongs_to :lead

  enum :kind, { visit: 0, followup: 1, other: 2 }

  validates :kind, :due_at, presence: true

  scope :pending, -> { where(done: false) }
  scope :completed, -> { where(done: true) }
  scope :overdue, -> { where('due_at < ? AND done = ?', Time.current, false) }
end
