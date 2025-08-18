FactoryBot.define do
  factory :offer_item do
    offer { nil }
    name { "MyString" }
    qty { 1 }
    unit_price_cents { 1 }
  end
end
