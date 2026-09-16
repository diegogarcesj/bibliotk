puts "Limpiando base de datos..."

Review.delete_all
Book.delete_all
User.delete_all

puts "Creando usuarios..."

users = 100.times.map do |i|
  User.create!
end

puts "Creando 50 libros..."

books = 50.times.map do |i|
  Book.create!(
    title: Faker::Book.title,
    reviews_sum: 0,
    reviews_count: 0
  )
end

puts "Creando reseñas..."

books.each do |book|
  reviewers = users.sample(rand(2..20))

  reviewers.each do |user|
    Review.create!(
      user: user,
      book: book,
      rating: rand(1..5),
      content: Faker::Lorem.sentence
    )
  end

  Books::RebuildReviewStats.call(book)
end

puts
puts "Seed completado:"
puts "  Users:   #{User.count}"
puts "  Books:   #{Book.count}"
puts "  Reviews: #{Review.count}"