class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :lead, null: false, foreign_key: true
      t.integer :kind
      t.datetime :due_at
      t.boolean :done, default: false, null: false

      t.timestamps
    end
  end
end
