class BoilerCalculation < ApplicationRecord
  belongs_to :lead
  belongs_to :created_by, class_name: 'User'
  
  validates :heating_area, presence: true, numericality: { greater_than: 0 }
  validates :current_heating_type, presence: true
  validates :desired_power, numericality: { greater_than: 0 }, allow_blank: true
  validates :estimated_cost, numericality: { greater_than: 0 }, allow_blank: true
  
  HEATING_TYPES = {
    'coal' => 'Węgiel',
    'gas' => 'Gaz', 
    'oil' => 'Olej',
    'electric' => 'Elektryczne',
    'wood' => 'Drewno',
    'heat_pump' => 'Pompa ciepła',
    'other' => 'Inne'
  }.freeze
  
  validates :current_heating_type, inclusion: { in: HEATING_TYPES.keys }
  
  # Automatic power calculation based on heating area
  before_save :calculate_recommended_power
  
  scope :recent, -> { order(created_at: :desc) }
  
  def self.heating_types_for_select
    HEATING_TYPES.map { |key, value| [value, key] }
  end
  
  def recommended_power_range
    return nil unless heating_area.present?
    
    base_power = heating_area * 0.1 # 100W per m²
    min_power = (base_power * 0.8).round(1)
    max_power = (base_power * 1.2).round(1)
    
    "#{min_power} - #{max_power} kW"
  end
  
  def efficiency_improvement
    return nil unless current_heating_type.present?
    
    case current_heating_type
    when 'coal' then '85%'
    when 'gas' then '25%'
    when 'oil' then '35%'
    when 'electric' then '65%'
    when 'wood' then '40%'
    when 'heat_pump' then '15%'
    else '30%'
    end
  end
  
  private
  
  def calculate_recommended_power
    if heating_area.present? && desired_power.blank?
      self.desired_power = (heating_area * 0.1).round(1)
    end
  end
end
