FactoryBot.define do
  factory :comment do
    body { "MyText" }
    association :post
  end
end
