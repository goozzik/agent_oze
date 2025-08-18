class CreateBoilerCalculations < ActiveRecord::Migration[8.0]
  def change
    create_table :boiler_calculations do |t|
      t.references :lead, null: false, foreign_key: true
      t.decimal :heating_area
      t.string :current_heating_type
      t.decimal :desired_power
      t.string :recommended_boiler
      t.text :calculation_notes
      t.decimal :estimated_cost
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
