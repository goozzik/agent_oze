class Measurement < ApplicationRecord
  belongs_to :lead
  belongs_to :measured_by, class_name: 'User'
  
  validates :measurement_type, presence: true
  validates :room_name, presence: true
  validates :length, presence: true, numericality: { greater_than: 0 }
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, numericality: { greater_than: 0 }, allow_blank: true
  
  MEASUREMENT_TYPES = {
    'room' => 'Pomieszczenie',
    'building' => 'Budynek',
    'heating_zone' => 'Strefa grzewcza',
    'installation_space' => 'Miejsce instalacji'
  }.freeze
  
  validates :measurement_type, inclusion: { in: MEASUREMENT_TYPES.keys }
  
  # Automatic calculations
  before_save :calculate_area_and_volume
  
  scope :by_type, ->(type) { where(measurement_type: type) }
  scope :recent, -> { order(created_at: :desc) }
  
  def self.measurement_types_for_select
    MEASUREMENT_TYPES.map { |key, value| [value, key] }
  end
  
  def total_area
    area || (length * width if length && width)
  end
  
  def total_volume
    volume || (length * width * height if length && width && height)
  end
  
  def heating_requirement
    return nil unless total_area
    
    # Basic calculation: 100W per m² for standard insulation
    base_requirement = total_area * 0.1
    
    case measurement_type
    when 'room'
      base_requirement
    when 'building'
      base_requirement * 0.9 # Slight reduction for whole building efficiency
    when 'heating_zone'
      base_requirement * 1.1 # Increase for specific zones
    when 'installation_space'
      base_requirement * 0.8 # Reduce for technical spaces
    else
      base_requirement
    end.round(2)
  end
  
  private
  
  def calculate_area_and_volume
    self.area = length * width if length && width
    self.volume = length * width * height if length && width && height
  end
end
