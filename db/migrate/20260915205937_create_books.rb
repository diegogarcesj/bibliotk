class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.bigint :reviews_sum, null: false, default: 0
      t.bigint :reviews_count, null: false, default: 0

      t.timestamps
    end

    add_check_constraint :books,
      "reviews_sum >= 0",
      name: "books_reviews_sum_non_negative"

    add_check_constraint :books,
      "reviews_count >= 0",
      name: "books_reviews_count_non_negative"
  end
end
