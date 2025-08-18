FactoryBot.define do
  factory :offer do
    lead { nil }
    number { "MyString" }
    total_cents { 1 }
    currency { "MyString" }
    description { "MyText" }
    sent_at { "2025-08-16 16:21:19" }
    status { 1 }
  end
end
