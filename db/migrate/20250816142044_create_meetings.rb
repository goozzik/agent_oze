class CreateMeetings < ActiveRecord::Migration[8.0]
  def change
    create_table :meetings do |t|
      t.references :lead, null: false, foreign_key: true
      t.datetime :scheduled_at
      t.string :location
      t.text :notes

      t.timestamps
    end
  end
end
