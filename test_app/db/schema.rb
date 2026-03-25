# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_21_222746) do
  create_table "attendees", force: :cascade do |t|
    t.integer "age"
    t.datetime "created_at", null: false
    t.string "dietary_requirements"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.json "metadata"
    t.string "phone"
    t.integer "registration_id", null: false
    t.integer "sort_order"
    t.datetime "updated_at", null: false
    t.index ["registration_id"], name: "index_attendees_on_registration_id"
  end

  create_table "contact_submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "ip_address"
    t.string "last_name"
    t.boolean "marketing_consent"
    t.text "message"
    t.string "phone"
    t.string "postal_code"
    t.datetime "updated_at", null: false
    t.string "user_agent"
  end

  create_table "materials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "hidden", default: false
    t.string "name"
    t.integer "quantity"
    t.decimal "unit_cost"
    t.datetime "updated_at", null: false
    t.integer "workshop_id", null: false
    t.index ["workshop_id"], name: "index_materials_on_workshop_id"
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "rich_content_id"
    t.boolean "system", default: false
    t.datetime "updated_at", null: false
  end

  create_table "registrations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.text "notes"
    t.string "phone"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.integer "workshop_id", null: false
    t.index ["workshop_id"], name: "index_registrations_on_workshop_id"
  end

  create_table "rich_contents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "markdown"
    t.datetime "updated_at", null: false
  end

  create_table "workshops", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.integer "description_id"
    t.date "end_date"
    t.boolean "hidden", default: false
    t.integer "max_capacity"
    t.integer "pricing_info_id"
    t.string "slug"
    t.date "start_date"
    t.string "status", default: "draft"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_workshops_on_slug", unique: true
  end

  add_foreign_key "attendees", "registrations"
  add_foreign_key "materials", "workshops"
  add_foreign_key "registrations", "workshops"
end
