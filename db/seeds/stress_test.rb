REVIEW_COUNT = 500_000
BATCH_SIZE = 10_000

book = Book.first!

puts "Libro seleccionado:"
puts "  ID:    #{book.id}"
puts "  Título: #{book.title}"
puts
puts "Creando #{REVIEW_COUNT} usuarios..."

now = Time.current

user_ids = []

REVIEW_COUNT.times.each_slice(BATCH_SIZE) do |batch|
  rows = batch.map do
    {
      banned_at: nil,
      created_at: now,
      updated_at: now
    }
  end

  result = User.insert_all!(
    rows,
    returning: [:id]
  )

  user_ids.concat(result.rows.flatten)

  puts "Usuarios creados: #{user_ids.size}/#{REVIEW_COUNT}"
end

puts
puts "Creando #{REVIEW_COUNT} reviews..."

inserted_reviews = 0

user_ids.each_slice(BATCH_SIZE) do |batch_user_ids|
  rows = batch_user_ids.map do |user_id|
    {
      user_id: user_id,
      book_id: book.id,
      rating: rand(1..5),
      content: "Reseña de prueba de carga",
      created_at: now,
      updated_at: now
    }
  end

  Review.insert_all!(rows)

  inserted_reviews += rows.size

  puts "Reviews creadas: #{inserted_reviews}/#{REVIEW_COUNT}"
end

puts
puts "Recalculando estadísticas..."

Books::RebuildReviewStats.call(book)

book.reload

puts
puts "Seed de carga completado:"
puts "  Book ID:       #{book.id}"
puts "  Reviews count: #{book.reviews_count}"
puts "  Reviews sum:   #{book.reviews_sum}"
puts "  Rating:        #{book.rating_display.inspect}"