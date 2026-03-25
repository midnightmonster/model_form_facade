class CreateAttendees < ActiveRecord::Migration[8.1]
  def change
    create_table :attendees do |t|
      t.references :registration, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :dietary_requirements
      t.integer :age
      t.integer :sort_order
      t.json :metadata

      t.timestamps
    end
  end
end
