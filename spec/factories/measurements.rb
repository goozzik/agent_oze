FactoryBot.define do
  factory :measurement do
    lead { nil }
    measurement_type { "MyString" }
    room_name { "MyString" }
    length { "9.99" }
    width { "9.99" }
    height { "9.99" }
    area { "9.99" }
    volume { "9.99" }
    notes { "MyText" }
    measured_by { nil }
  end
end
