class CreateOfferItems < ActiveRecord::Migration[8.0]
  def change
    create_table :offer_items do |t|
      t.references :offer, null: false, foreign_key: true
      t.string :name
      t.integer :qty
      t.integer :unit_price_cents

      t.timestamps
    end
  end
end
