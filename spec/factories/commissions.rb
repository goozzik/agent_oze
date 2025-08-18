FactoryBot.define do
  factory :commission do
    lead { nil }
    amount_cents { 1 }
    booked_at { "2025-08-16 16:21:38" }
    notes { "MyText" }
  end
end
