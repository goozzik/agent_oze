class CreateCommissions < ActiveRecord::Migration[8.0]
  def change
    create_table :commissions do |t|
      t.references :lead, null: false, foreign_key: true
      t.integer :amount_cents
      t.datetime :booked_at
      t.text :notes

      t.timestamps
    end
  end
end
