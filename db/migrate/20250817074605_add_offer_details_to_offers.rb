class AddOfferDetailsToOffers < ActiveRecord::Migration[8.0]
  def change
    add_column :offers, :delivery_time, :string
    add_column :offers, :warranty, :string
    add_column :offers, :bonuses, :text
  end
end
