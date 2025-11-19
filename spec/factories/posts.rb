FactoryBot.define do
  factory :post do
    title { "Sample Post Title" }
    body { "This is a sample post body content." }
    association :topic
  end
end

