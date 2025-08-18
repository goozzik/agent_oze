class CreateMeasurements < ActiveRecord::Migration[8.0]
  def change
    create_table :measurements do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :measurement_type
      t.string :room_name
      t.decimal :length
      t.decimal :width
      t.decimal :height
      t.decimal :area
      t.decimal :volume
      t.text :notes
      t.references :measured_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
