class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :content

      t.timestamps
    end

    add_index :reviews, [:user_id, :book_id], unique: true

    add_check_constraint :reviews,
      "rating BETWEEN 1 AND 5",
      name: "reviews_rating_range"

    add_check_constraint :reviews,
      "content IS NULL OR char_length(content) <= 1000",
      name: "reviews_content_max_length"
  end
end
