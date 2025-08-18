class CreateInstallationNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :installation_notes do |t|
      t.references :lead, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
