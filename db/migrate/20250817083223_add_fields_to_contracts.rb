class AddFieldsToContracts < ActiveRecord::Migration[8.0]
  def change
    add_column :contracts, :description, :text
    add_column :contracts, :terms, :text
    add_column :contracts, :total_amount_cents, :integer
    add_column :contracts, :payment_terms, :string
    add_column :contracts, :delivery_date, :date
    add_column :contracts, :warranty_period, :string
    add_column :contracts, :special_conditions, :text
    add_column :contracts, :sent_at, :datetime
  end
end
