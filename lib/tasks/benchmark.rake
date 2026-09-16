require "benchmark"

namespace :benchmark do
  desc "Mide el rendimiento del listado de 50 libros"
  task books_index: :environment do
    iterations = ENV.fetch("ITERATIONS", 100).to_i

    puts "Benchmark Books Index"
    puts "====================="
    puts "Books: #{Book.count}"
    puts "Reviews: #{Review.count}"
    puts "Iterations: #{iterations}"
    puts

    # Warm-up: evita que la primera ejecución distorsione
    # demasiado la medición.
    5.times do
      Book
        .order(:id)
        .limit(50)
        .map(&:rating_display)
    end

    elapsed = Benchmark.realtime do
      iterations.times do
        books = Book
          .order(:id)
          .limit(50)
          .to_a

        books.each(&:rating_display)
      end
    end

    average_ms = (elapsed / iterations) * 1000

    puts "Total time:  #{elapsed.round(4)} s"
    puts "Average:     #{average_ms.round(3)} ms"
    puts "Per second:  #{(iterations / elapsed).round(2)} iterations/s"
  end
end