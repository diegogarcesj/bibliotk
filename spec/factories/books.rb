FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    reviews_sum { 0 }
    reviews_count { 0 }
  end
end