FactoryBot.define do
  factory :meeting do
    lead { nil }
    scheduled_at { "2025-08-16 16:20:44" }
    location { "MyString" }
    notes { "MyText" }
  end
end
