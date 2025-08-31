class AddAdvancedFieldsToEnergyAudits < ActiveRecord::Migration[8.0]
  def change
    add_column :energy_audits, :wall_u_value, :decimal
    add_column :energy_audits, :window_u_value, :decimal
    add_column :energy_audits, :roof_u_value, :decimal
    add_column :energy_audits, :floor_u_value, :decimal
    add_column :energy_audits, :building_volume, :decimal
    add_column :energy_audits, :glazed_area_percentage, :decimal
    add_column :energy_audits, :air_tightness_n50, :decimal
    add_column :energy_audits, :ventilation_heat_recovery_efficiency, :decimal
    add_column :energy_audits, :climate_zone, :string
    add_column :energy_audits, :heating_degree_days, :integer
    add_column :energy_audits, :external_design_temperature, :integer
  end
end
