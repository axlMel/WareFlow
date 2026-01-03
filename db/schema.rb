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

ActiveRecord::Schema[8.0].define(version: 2026_01_02_210226) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "delivery_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "folio_id", null: false
    t.bigint "user_id", null: false
    t.index ["delivery_id"], name: "index_assignments_on_delivery_id"
    t.index ["folio_id"], name: "index_assignments_on_folio_id"
    t.index ["product_id"], name: "index_assignments_on_product_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deliveries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "client"
    t.integer "folio_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folio_id"], name: "index_deliveries_on_folio_id"
    t.index ["user_id"], name: "index_deliveries_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_favorites_on_product_id"
    t.index ["user_id", "product_id"], name: "index_favorites_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "folios", force: :cascade do |t|
    t.string "client"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "service"
    t.string "accessories"
    t.integer "status", default: 0, null: false
    t.index ["user_id"], name: "index_folios_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.integer "price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id", null: false
    t.bigint "user_id", null: false
    t.integer "stock"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "user_id", null: false
    t.integer "quantity", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "user_id"], name: "index_stocks_on_product_id_and_user_id", unique: true
    t.index ["product_id"], name: "index_stocks_on_product_id"
    t.index ["user_id"], name: "index_stocks_on_user_id"
  end

  create_table "support_assignments", force: :cascade do |t|
    t.bigint "support_id", null: false
    t.bigint "assignment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_support_assignments_on_assignment_id"
    t.index ["support_id", "assignment_id"], name: "index_support_assignments_on_support_id_and_assignment_id", unique: true
    t.index ["support_id"], name: "index_support_assignments_on_support_id"
  end

  create_table "supports", force: :cascade do |t|
    t.string "service"
    t.string "client"
    t.string "car_type"
    t.string "plate"
    t.string "eco"
    t.text "commit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "folio_id"
    t.bigint "user_id"
    t.index ["folio_id"], name: "index_supports_on_folio_id"
    t.index ["user_id"], name: "index_supports_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "username", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.string "country"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "warranties", force: :cascade do |t|
    t.string "client"
    t.text "commit"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "assignment_id"
    t.bigint "user_id"
    t.bigint "product_id"
    t.index ["assignment_id"], name: "index_warranties_on_assignment_id"
    t.index ["product_id"], name: "index_warranties_on_product_id"
    t.index ["user_id"], name: "index_warranties_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assignments", "deliveries"
  add_foreign_key "assignments", "folios"
  add_foreign_key "assignments", "products"
  add_foreign_key "assignments", "users"
  add_foreign_key "deliveries", "folios"
  add_foreign_key "deliveries", "users"
  add_foreign_key "favorites", "products"
  add_foreign_key "favorites", "users"
  add_foreign_key "folios", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "users"
  add_foreign_key "stocks", "products"
  add_foreign_key "stocks", "users"
  add_foreign_key "support_assignments", "assignments"
  add_foreign_key "support_assignments", "supports"
  add_foreign_key "supports", "folios"
  add_foreign_key "supports", "users"
  add_foreign_key "warranties", "assignments"
  add_foreign_key "warranties", "products"
  add_foreign_key "warranties", "users"
end
