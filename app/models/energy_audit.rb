class EnergyAudit < ApplicationRecord
  belongs_to :lead
  
  # Energy audit constants
  HEAT_SOURCES = {
    'coal' => 'Węgiel',
    'gas' => 'Gaz',
    'oil' => 'Olej opałowy',
    'electric' => 'Energia elektryczna',
    'biomass' => 'Biomasa',
    'heat_pump' => 'Pompa ciepła',
    'solar' => 'Kolektory słoneczne',
    'other' => 'Inne'
  }.freeze
  
  HOUSE_CONDITIONS = {
    'excellent' => 'Bardzo dobry',
    'good' => 'Dobry', 
    'average' => 'Średni',
    'poor' => 'Słaby',
    'very_poor' => 'Bardzo słaby'
  }.freeze
  
  VENTILATION_TYPES = {
    'natural' => 'Grawitacyjna',
    'mechanical' => 'Mechaniczna',
    'recuperation' => 'Rekuperacja',
    'mixed' => 'Mieszana'
  }.freeze
  
  ENERGY_CLASSES = %w[A+ A B C D E F G].freeze

  # Climate zones in Poland
  CLIMATE_ZONES = {
    'I' => 'Strefa I (wybrzeże)',
    'II' => 'Strefa II (niziny)',
    'III' => 'Strefa III (wyżyny)',
    'IV' => 'Strefa IV (podgórze)',
    'V' => 'Strefa V (góry)'
  }.freeze

  # Primary energy factors (Wi) according to Polish regulations
  PRIMARY_ENERGY_FACTORS = {
    'coal' => 1.1,
    'gas' => 1.1,
    'oil' => 1.1,
    'electric' => 3.0,
    'biomass' => 0.2,
    'heat_pump' => 2.5, # depends on COP
    'district_heating' => 1.3,
    'solar' => 0.0
  }.freeze

  # System efficiencies by type and age
  SYSTEM_EFFICIENCIES = {
    'coal' => { old: 0.65, medium: 0.75, new: 0.85 },
    'gas' => { old: 0.78, medium: 0.88, new: 0.95 },
    'oil' => { old: 0.72, medium: 0.82, new: 0.90 },
    'electric' => { old: 0.95, medium: 0.98, new: 0.99 },
    'biomass' => { old: 0.70, medium: 0.80, new: 0.90 },
    'heat_pump' => { old: 2.8, medium: 3.5, new: 4.5 }, # COP values
    'pellets' => { old: 0.75, medium: 0.85, new: 0.92 }
  }.freeze
  
  validates :construction_year, presence: true, 
            numericality: { greater_than: 1800, less_than_or_equal_to: Date.current.year }
  validates :usable_area, presence: true, numericality: { greater_than: 0 }
  validates :current_heat_source, presence: true, inclusion: { in: HEAT_SOURCES.keys }
  validates :house_condition, presence: true, inclusion: { in: HOUSE_CONDITIONS.keys }
  validates :ventilation_type, presence: true, inclusion: { in: VENTILATION_TYPES.keys }
  validates :energy_class, inclusion: { in: ENERGY_CLASSES }, allow_blank: true
  validates :climate_zone, inclusion: { in: CLIMATE_ZONES.keys }, allow_blank: true
  
  # Validates U-values (thermal transmittance) - typical ranges for Polish buildings
  validates :wall_u_value, numericality: { greater_than: 0, less_than: 3.0 }, allow_blank: true
  validates :window_u_value, numericality: { greater_than: 0, less_than: 5.0 }, allow_blank: true
  validates :roof_u_value, numericality: { greater_than: 0, less_than: 2.0 }, allow_blank: true
  validates :floor_u_value, numericality: { greater_than: 0, less_than: 2.0 }, allow_blank: true
  validates :building_volume, numericality: { greater_than: 0 }, allow_blank: true
  validates :glazed_area_percentage, numericality: { greater_than: 0, less_than: 100 }, allow_blank: true
  validates :air_tightness_n50, numericality: { greater_than: 0, less_than: 20 }, allow_blank: true
  validates :ventilation_heat_recovery_efficiency, numericality: { greater_than: 0, less_than: 100 }, allow_blank: true
  
  # Check if we have enough data for detailed EP/EC/ET calculations
  def has_detailed_building_data?
    [wall_u_value, window_u_value, roof_u_value, floor_u_value, 
     building_volume, climate_zone].all?(&:present?)
  end
  
  # Check if we have heating system efficiency data
  def has_heating_system_data?
    [current_system_efficiency, fuel_type_current].all?(&:present?)
  end
  
  # Auto-determine climate zone from location_info
  def auto_determine_climate_zone
    return nil unless location_info.present?
    
    location_lower = location_info.downcase
    
    # Coastal regions (Zone I)
    if location_lower.match?(/gdańsk|gdynia|sopot|szczecin|koszalin|słupsk|elbląg|wybrzeże|pomorze/)
      return 'I'
    # Lowlands (Zone II)  
    elsif location_lower.match?(/warszawa|łódź|poznań|wrocław|kraków|lublin|białystok|olsztyn|toruń|płock/)
      return 'II'
    # Highlands (Zone III)
    elsif location_lower.match?(/katowice|częstochowa|kielce|rzeszów|lublin|zamość|śląsk|małopolsk/)
      return 'III'
    # Foothills (Zone IV)
    elsif location_lower.match?(/bielsko|nowy sącz|tarnów|przemyśl|podkarpacie/)
      return 'IV'
    # Mountains (Zone V)
    elsif location_lower.match?(/zakopane|podhale|tatry|beskid|sudety|karpaty|góry/)
      return 'V'
    else
      return 'II' # Default to Zone II (most common)
    end
  end
  
  # Get heating degree days for climate zone
  def get_heating_degree_days
    zone = climate_zone || auto_determine_climate_zone
    
    case zone
    when 'I' then 3200  # Coast
    when 'II' then 3600 # Lowlands  
    when 'III' then 3800 # Highlands
    when 'IV' then 4200 # Foothills
    when 'V' then 4800  # Mountains
    else 3600 # Default
    end
  end
  
  # Get external design temperature for climate zone
  def get_external_design_temperature
    zone = climate_zone || auto_determine_climate_zone
    
    case zone
    when 'I' then -16   # Coast
    when 'II' then -20  # Lowlands
    when 'III' then -22 # Highlands  
    when 'IV' then -24  # Foothills
    when 'V' then -26   # Mountains
    else -20 # Default
    end
  end
  
  # Get current system efficiency based on type and estimated age
  def get_current_system_efficiency
    return current_system_efficiency / 100.0 if current_system_efficiency.present?
    
    # Estimate based on building age and heat source type
    system_age_category = case construction_year
                         when 2010..Float::INFINITY then :new
                         when 1990..2009 then :medium  
                         else :old
                         end
    
    efficiency_data = SYSTEM_EFFICIENCIES[current_heat_source]
    return 0.7 unless efficiency_data # Default fallback
    
    efficiency_data[system_age_category] || 0.7
  end
  
  # Get primary energy factor for current fuel
  def get_current_primary_energy_factor
    return primary_energy_factor_current if primary_energy_factor_current.present?
    
    fuel = fuel_type_current.presence || current_heat_source
    PRIMARY_ENERGY_FACTORS[fuel] || 1.1
  end
  
  # Get proposed system efficiency
  def get_proposed_system_efficiency
    return proposed_system_efficiency / 100.0 if proposed_system_efficiency.present?
    
    # Default high-efficiency values for modern systems (as decimals)
    case proposed_system_type
    when 'pellets' then 0.92
    when 'heat_pump' then 4.0 # COP
    when 'gas' then 0.95
    when 'biomass' then 0.90
    else 0.85
    end
  end
  
  # Get proposed primary energy factor
  def get_proposed_primary_energy_factor
    return primary_energy_factor_proposed if primary_energy_factor_proposed.present?
    
    fuel = fuel_type_proposed.presence || proposed_system_type
    PRIMARY_ENERGY_FACTORS[fuel] || 0.2
  end
  
  # Calculate energy demand based on building parameters
  def calculate_energy_demand
    return nil unless usable_area && construction_year
    
    # Base demand per m2 based on construction year
    base_demand = case construction_year
                  when 2021..Float::INFINITY then 70   # New buildings
                  when 2014..2020 then 90              # Recent buildings
                  when 2000..2013 then 120             # Modern buildings
                  when 1980..1999 then 150             # Older buildings
                  when 1960..1979 then 180             # Old buildings
                  else 220                             # Very old buildings
                  end
    
    # Adjust for house condition
    condition_multiplier = case house_condition
                          when 'excellent' then 0.8
                          when 'good' then 0.9
                          when 'average' then 1.0
                          when 'poor' then 1.2
                          when 'very_poor' then 1.4
                          else 1.0
                          end
    
    # Calculate total demand
    total_demand = usable_area * base_demand * condition_multiplier
    total_demand.round(0)
  end
  
  # Generate AI-powered recommendations
  def generate_recommendations
    recommendations = []
    
    # Age-based recommendations
    if construction_year < 1980
      recommendations << "🏠 Kompleksowa termomodernizacja budynku ze względu na wiek"
      recommendations << "🔥 Wymiana systemu grzewczego na nowoczesny i ekologiczny"
    elsif construction_year < 2000
      recommendations << "🔥 Modernizacja systemu grzewczego"
      recommendations << "🪟 Wymiana okien na energooszczędne"
    end
    
    # Heat source recommendations
    if current_heat_source == 'coal'
      recommendations << "⚡ Pilna wymiana kotła węglowego na piec pelletowy lub pompę ciepła"
      recommendations << "🌱 Dofinansowanie z programów ekologicznych (Czyste Powietrze, Mój Prąd)"
    elsif current_heat_source == 'oil'
      recommendations << "🔥 Wymiana kotła olejowego na bardziej ekologiczne rozwiązanie"
    end
    
    # Condition-based recommendations  
    case house_condition
    when 'poor', 'very_poor'
      recommendations << "🏠 Pilna termomodernizacja - docieplenie ścian, dachu, wyiana okien"
      recommendations << "💡 Audyt energetyczny przed rozpoczęciem prac"
    when 'average'
      recommendations << "🔍 Szczegółowy audyt energetyczny w celu identyfikacji strat ciepła"
      recommendations << "🌡️ Montaż systemu zarządzania temperaturą"
    end
    
    # Area-based recommendations
    if usable_area && usable_area > 200
      recommendations << "💨 System rekuperacji ze względu na dużą powierzchnię"
      recommendations << "🔋 Rozważenie instalacji fotowoltaicznej"
    end
    
    recommendations.join("\n")
  end
  
  # Determine energy class based on calculated demand
  def determine_energy_class
    demand = calculate_energy_demand
    return nil unless demand && usable_area
    
    demand_per_m2 = demand / usable_area
    
    case demand_per_m2
    when 0..30 then 'A+'
    when 31..50 then 'A'
    when 51..70 then 'B'
    when 71..100 then 'C'
    when 101..150 then 'D'
    when 151..200 then 'E'
    when 201..250 then 'F'
    else 'G'
    end
  end
  
  # Calculate detailed transmission losses (ET) - building envelope efficiency
  def calculate_transmission_losses_et
    return nil unless has_detailed_building_data?
    
    # Simplified calculation based on U-values and building geometry
    # ET = Sum of (U-value × Area × Temperature difference)
    
    # Estimate building envelope areas (simplified geometric approach)
    total_wall_area = (usable_area * 0.5) # Rough estimate: 50% more than floor area
    total_window_area = total_wall_area * (glazed_area_percentage || 15) / 100
    actual_wall_area = total_wall_area - total_window_area
    roof_area = usable_area # Assume roof area ≈ floor area
    floor_area = usable_area
    
    # Temperature difference (interior 20°C - exterior design temp)
    temp_diff = 20 - get_external_design_temperature
    
    # Transmission losses [W/K]
    transmission_coefficient = (
      (wall_u_value * actual_wall_area) +
      (window_u_value * total_window_area) +
      (roof_u_value * roof_area) +
      (floor_u_value * floor_area)
    )
    
    # ET in kWh/m²/year
    heating_hours = get_heating_degree_days * 24 / temp_diff
    et = (transmission_coefficient * temp_diff * heating_hours) / (1000 * usable_area)
    
    et.round(1)
  end
  
  # Calculate final energy demand (EC) - energy at building boundary  
  def calculate_final_energy_ec(system_efficiency = nil)
    base_demand = calculate_energy_demand
    return nil unless base_demand
    
    efficiency = system_efficiency || get_current_system_efficiency
    
    # EC = Base demand / system efficiency
    ec = base_demand / efficiency
    ec_per_m2 = ec / usable_area
    
    ec_per_m2.round(1)
  end
  
  # Calculate primary energy (EP) - total energy including losses
  def calculate_primary_energy_ep(system_efficiency = nil, primary_factor = nil)
    ec = calculate_final_energy_ec(system_efficiency)
    return nil unless ec
    
    factor = primary_factor || get_current_primary_energy_factor
    
    # EP = EC × primary energy factor
    ep = ec * factor
    ep.round(1)
  end
  
  # Calculate before/after investment scenarios
  def calculate_investment_scenarios
    scenarios = {}
    
    # BEFORE (current state)
    scenarios[:before] = {
      et: calculate_transmission_losses_et,
      ec: calculate_final_energy_ec,
      ep: calculate_primary_energy_ep,
      energy_class: determine_energy_class,
      system_efficiency: get_current_system_efficiency,
      primary_energy_factor: get_current_primary_energy_factor
    }
    
    # AFTER scenarios
    if proposed_system_type.present?
      proposed_efficiency = get_proposed_system_efficiency
      proposed_factor = get_proposed_primary_energy_factor
      
      scenarios[:after_heating] = {
        et: calculate_transmission_losses_et, # Same building envelope
        ec: calculate_final_energy_ec(proposed_efficiency),
        ep: calculate_primary_energy_ep(proposed_efficiency, proposed_factor),
        energy_class: determine_energy_class_for_ep(
          calculate_primary_energy_ep(proposed_efficiency, proposed_factor)
        ),
        system_efficiency: proposed_efficiency,
        primary_energy_factor: proposed_factor
      }
    end
    
    # Calculate energy savings
    if scenarios[:before][:ep] && scenarios[:after_heating]&.dig(:ep)
      scenarios[:savings] = {
        ep_reduction: scenarios[:before][:ep] - scenarios[:after_heating][:ep],
        ec_reduction: scenarios[:before][:ec] - scenarios[:after_heating][:ec],
        percentage_savings: (
          (scenarios[:before][:ep] - scenarios[:after_heating][:ep]) / 
          scenarios[:before][:ep] * 100
        ).round(1)
      }
    end
    
    scenarios
  end
  
  # Determine energy class based on EP value
  def determine_energy_class_for_ep(ep_value)
    return nil unless ep_value
    
    case ep_value
    when 0..50 then 'A+'
    when 51..70 then 'A'  
    when 71..100 then 'B'
    when 101..150 then 'C'
    when 151..200 then 'D'
    when 201..280 then 'E'
    when 281..350 then 'F'
    else 'G'
    end
  end
  
  # Calculate annual heating costs and savings
  def calculate_cost_analysis
    costs = {}
    
    # Current annual heating costs
    if current_energy_consumption.present? && has_heating_system_data?
      # Use actual consumption if provided
      annual_consumption = current_energy_consumption
    else
      # Estimate from calculated demand
      annual_consumption = calculate_energy_demand || (usable_area * 120) # Fallback
    end
    
    # Fuel prices (PLN per kWh/unit) - approximate 2024 prices
    fuel_prices = {
      'coal' => 0.45,      # PLN per kWh
      'gas' => 0.65,       # PLN per kWh  
      'oil' => 0.75,       # PLN per kWh
      'electric' => 0.85,  # PLN per kWh
      'biomass' => 0.35,   # PLN per kWh
      'pellets' => 0.40,   # PLN per kWh
      'heat_pump' => 0.85  # PLN per kWh (electricity)
    }
    
    # Current fuel type and price
    current_fuel = fuel_type_current.presence || current_heat_source
    current_price = fuel_prices[current_fuel] || 0.5
    
    costs[:current] = {
      annual_consumption_kwh: annual_consumption,
      fuel_type: current_fuel,
      price_per_kwh: current_price,
      annual_cost: (annual_consumption * current_price).round(0),
      efficiency: get_current_system_efficiency
    }
    
    # Proposed system costs
    if proposed_system_type.present?
      proposed_fuel = fuel_type_proposed.presence || proposed_system_type
      proposed_price = fuel_prices[proposed_fuel] || 0.4
      proposed_efficiency = get_proposed_system_efficiency
      
      # Calculate new consumption based on efficiency improvement (inverse relationship)
      efficiency_ratio = get_current_system_efficiency / proposed_efficiency
      new_consumption = annual_consumption * efficiency_ratio
      
      costs[:proposed] = {
        annual_consumption_kwh: new_consumption.round(0),
        fuel_type: proposed_fuel,
        price_per_kwh: proposed_price,
        annual_cost: (new_consumption * proposed_price).round(0),
        efficiency: proposed_efficiency
      }
      
      # Calculate savings
      annual_savings = costs[:current][:annual_cost] - costs[:proposed][:annual_cost]
      costs[:savings] = {
        annual_savings_pln: annual_savings.round(0),
        percentage_savings: (annual_savings / costs[:current][:annual_cost] * 100).round(1),
        consumption_reduction_kwh: (annual_consumption - new_consumption).round(0),
        consumption_reduction_percent: ((annual_consumption - new_consumption) / annual_consumption * 100).round(1)
      }
      
      # Investment payback estimation (simplified)
      investment_costs = {
        'pellets' => 35000,     # Average pellet stove cost
        'heat_pump' => 45000,   # Average heat pump cost
        'gas' => 25000,         # Average gas condensing boiler
        'biomass' => 30000      # Average biomass boiler
      }
      
      investment_cost = investment_costs[proposed_system_type] || 30000
      payback_years = annual_savings > 0 ? (investment_cost / annual_savings).round(1) : nil
      
      costs[:investment] = {
        estimated_cost_pln: investment_cost,
        payback_period_years: payback_years,
        lifetime_savings_20_years: (annual_savings * 20 - investment_cost).round(0)
      }
    end
    
    costs
  end
  
  # Generate full audit report
  def generate_audit_report
    demand = calculate_energy_demand
    energy_class = determine_energy_class
    recommendations = generate_recommendations
    
    # Auto-determine climate zone if not set
    if climate_zone.blank? && location_info.present?
      self.climate_zone = auto_determine_climate_zone
      self.heating_degree_days = get_heating_degree_days
      self.external_design_temperature = get_external_design_temperature
    end
    
    # Build comprehensive report
    report = {
      building_info: {
        construction_year: construction_year,
        usable_area: usable_area,
        building_volume: building_volume,
        current_heat_source: HEAT_SOURCES[current_heat_source],
        house_condition: HOUSE_CONDITIONS[house_condition],
        ventilation_type: VENTILATION_TYPES[ventilation_type],
        climate_zone: climate_zone ? CLIMATE_ZONES[climate_zone] : nil,
        heating_degree_days: get_heating_degree_days,
        external_design_temperature: get_external_design_temperature
      },
      energy_analysis: {
        annual_demand: demand,
        demand_per_m2: demand ? (demand / usable_area).round(1) : nil,
        energy_class: energy_class
      },
      thermal_properties: has_detailed_building_data? ? {
        wall_u_value: wall_u_value,
        window_u_value: window_u_value,
        roof_u_value: roof_u_value,
        floor_u_value: floor_u_value,
        glazed_area_percentage: glazed_area_percentage,
        air_tightness_n50: air_tightness_n50,
        ventilation_heat_recovery_efficiency: ventilation_heat_recovery_efficiency
      } : nil,
      professional_calculations: has_detailed_building_data? ? {
        et: calculate_transmission_losses_et,
        ec: calculate_final_energy_ec,
        ep: calculate_primary_energy_ep,
        current_system_efficiency: get_current_system_efficiency,
        primary_energy_factor: get_current_primary_energy_factor
      } : nil,
      investment_scenarios: calculate_investment_scenarios,
      cost_analysis: calculate_cost_analysis,
      recommendations: recommendations
    }
    
    # Update database with results and auto-determined values
    update_attributes = {
      audit_results: report.to_json,
      energy_class: energy_class,
      recommendations: recommendations
    }
    
    if climate_zone.blank? && location_info.present?
      update_attributes[:climate_zone] = auto_determine_climate_zone
      update_attributes[:heating_degree_days] = get_heating_degree_days
      update_attributes[:external_design_temperature] = get_external_design_temperature
    end
    
    self.update!(update_attributes)
    
    report
  end
end
