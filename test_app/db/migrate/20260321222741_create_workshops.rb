class CreateWorkshops < ActiveRecord::Migration[8.1]
  def change
    create_table :workshops do |t|
      t.string :title
      t.string :slug
      t.string :category
      t.string :status, default: "draft"
      t.boolean :hidden, default: false
      t.integer :max_capacity
      t.date :start_date
      t.date :end_date
      t.integer :description_id
      t.integer :pricing_info_id

      t.timestamps
    end
    add_index :workshops, :slug, unique: true
  end
end
