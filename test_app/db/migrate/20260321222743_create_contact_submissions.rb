class CreateContactSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_submissions do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :postal_code
      t.text :message
      t.boolean :marketing_consent
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
