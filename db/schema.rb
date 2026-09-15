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

ActiveRecord::Schema[8.1].define(version: 2026_09_15_210012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "reviews_count", default: 0, null: false
    t.bigint "reviews_sum", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "reviews_count >= 0", name: "books_reviews_count_non_negative"
    t.check_constraint "reviews_sum >= 0", name: "books_reviews_sum_non_negative"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "rating", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_reviews_on_book_id"
    t.index ["user_id", "book_id"], name: "index_reviews_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.check_constraint "content IS NULL OR char_length(content) <= 1000", name: "reviews_content_max_length"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "reviews_rating_range"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "banned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "reviews", "books"
  add_foreign_key "reviews", "users"
end
