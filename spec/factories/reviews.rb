FactoryBot.define do
  factory :review do
    association :user
    association :book

    rating { rand(1..5) }
    content { Faker::Lorem.sentence }
  end
end