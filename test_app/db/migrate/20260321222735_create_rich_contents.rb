class CreateRichContents < ActiveRecord::Migration[8.1]
  def change
    create_table :rich_contents do |t|
      t.text :markdown

      t.timestamps
    end
  end
end
