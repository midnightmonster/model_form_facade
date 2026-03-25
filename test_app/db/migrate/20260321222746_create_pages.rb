class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.string :name
      t.boolean :system, default: false
      t.integer :rich_content_id

      t.timestamps
    end
  end
end
