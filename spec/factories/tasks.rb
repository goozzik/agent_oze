FactoryBot.define do
  factory :task do
    lead { nil }
    kind { 1 }
    due_at { "2025-08-16 16:21:44" }
    done { false }
  end
end
