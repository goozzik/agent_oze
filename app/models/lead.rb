class Lead < ApplicationRecord
  belongs_to :user, optional: true
  has_many :meetings, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :measurements, dependent: :destroy
  has_many :boiler_calculations, dependent: :destroy
  has_many :installation_notes, dependent: :destroy
  has_many :contracts, dependent: :destroy
  has_many :commissions, dependent: :destroy
  has_many_attached :photos

  enum :status, {
    fresh: 0,
    contacted: 1,
    meeting: 2,
    offer: 3,
    won: 4,
    lost: 5,
    followup: 6
  }

  def self.status_names_pl
    {
      'fresh' => 'Nowy',
      'contacted' => 'Kontakt',
      'meeting' => 'Spotkanie',
      'offer' => 'Oferta',
      'won' => 'Wygrany',
      'lost' => 'Przegrany',
      'followup' => 'Follow-up'
    }
  end

  def status_pl
    Lead.status_names_pl[status]
  end

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, format: { with: /\A[\d\s\-\+\(\)]+\z/ }
  validates :status, presence: true

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_source, ->(source) { where(source: source) if source.present? }

  def full_name
    "#{first_name} #{last_name}"
  end
end
