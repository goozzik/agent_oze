class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.text :address
      t.text :investment_address
      t.string :source
      t.string :product
      t.integer :status, default: 0, null: false
      t.text :notes
      t.text :lost_reason

      t.timestamps
    end
  end
end
