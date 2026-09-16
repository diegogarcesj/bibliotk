namespace :books do
  desc "Recalcula reviews_sum y reviews_count de un libro"
  task :rebuild_review_stats, [:book_id] => :environment do |_task, args|
    book_id = args[:book_id]

    if book_id.blank?
      abort "Uso: bin/rails books:rebuild_review_stats[BOOK_ID]"
    end

    book = Book.find(book_id)

    puts "Recalculando puntaje para '#{book.title}' (ID: #{book.id})..."
    puts "Antes: sum=#{book.reviews_sum}, count=#{book.reviews_count}"

    Books::RebuildReviewStats.call(book)

    book.reload

    puts "Después: sum=#{book.reviews_sum}, count=#{book.reviews_count}"
    puts "Rating: #{book.rating_display.inspect}"
  rescue ActiveRecord::RecordNotFound
    abort "No existe un libro con ID #{book_id}"
  end
end