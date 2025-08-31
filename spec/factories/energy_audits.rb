FactoryBot.define do
  factory :energy_audit do
    lead { nil }
    construction_year { 1 }
    usable_area { "9.99" }
    building_registry_number { "MyString" }
    current_heat_source { "MyString" }
    insulation_info { "MyText" }
    roof_info { "MyText" }
    attic_info { "MyText" }
    house_condition { "MyString" }
    planned_investments { "MyText" }
    current_energy_consumption { "9.99" }
    location_info { "MyString" }
    ventilation_type { "MyString" }
    expansion_plans { "MyText" }
    audit_results { "MyText" }
    energy_class { "MyString" }
    recommendations { "MyText" }
  end
end
