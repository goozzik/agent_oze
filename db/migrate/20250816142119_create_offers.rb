class CreateOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :offers do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :number
      t.integer :total_cents
      t.string :currency, default: 'PLN'
      t.text :description
      t.datetime :sent_at
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
