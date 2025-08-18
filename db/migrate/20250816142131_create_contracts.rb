class CreateContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :contracts do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :number
      t.datetime :signed_at

      t.timestamps
    end
  end
end
