class CreateEnergyAudits < ActiveRecord::Migration[8.0]
  def change
    create_table :energy_audits do |t|
      t.references :lead, null: false, foreign_key: true
      t.integer :construction_year
      t.decimal :usable_area
      t.string :building_registry_number
      t.string :current_heat_source
      t.text :insulation_info
      t.text :roof_info
      t.text :attic_info
      t.string :house_condition
      t.text :planned_investments
      t.decimal :current_energy_consumption
      t.string :location_info
      t.string :ventilation_type
      t.text :expansion_plans
      t.text :audit_results
      t.string :energy_class
      t.text :recommendations

      t.timestamps
    end
  end
end
