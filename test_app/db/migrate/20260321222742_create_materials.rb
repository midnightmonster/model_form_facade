class CreateMaterials < ActiveRecord::Migration[8.1]
  def change
    create_table :materials do |t|
      t.references :workshop, null: false, foreign_key: true
      t.string :name
      t.integer :quantity
      t.decimal :unit_cost
      t.boolean :hidden, default: false

      t.timestamps
    end
  end
end
