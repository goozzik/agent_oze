class AddHeatingSystemFieldsToEnergyAudits < ActiveRecord::Migration[8.0]
  def change
    add_column :energy_audits, :current_system_efficiency, :decimal
    add_column :energy_audits, :proposed_system_type, :string
    add_column :energy_audits, :proposed_system_efficiency, :decimal
    add_column :energy_audits, :fuel_type_current, :string
    add_column :energy_audits, :fuel_type_proposed, :string
    add_column :energy_audits, :primary_energy_factor_current, :decimal
    add_column :energy_audits, :primary_energy_factor_proposed, :decimal
  end
end
