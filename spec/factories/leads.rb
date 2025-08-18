FactoryBot.define do
  factory :lead do
    first_name { "MyString" }
    last_name { "MyString" }
    phone { "MyString" }
    email { "MyString" }
    address { "MyText" }
    investment_address { "MyText" }
    source { "MyString" }
    product { "MyString" }
    status { 1 }
    notes { "MyText" }
    lost_reason { "MyText" }
  end
end
