class AddDecisionStatusesToOffers < ActiveRecord::Migration[8.0]
  def change
    add_column :offers, :decision_status, :integer
    add_column :offers, :decision_made_at, :datetime
    add_column :offers, :decision_notes, :text
    add_column :offers, :customer_response, :text
  end
end
