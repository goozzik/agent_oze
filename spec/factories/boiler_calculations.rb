FactoryBot.define do
  factory :boiler_calculation do
    lead { nil }
    heating_area { "9.99" }
    current_heating_type { "MyString" }
    desired_power { "9.99" }
    recommended_boiler { "MyString" }
    calculation_notes { "MyText" }
    estimated_cost { "9.99" }
    created_by { nil }
  end
end
