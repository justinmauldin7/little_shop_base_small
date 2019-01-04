# FactoryBot.define do
#   factory :rating, class: Rating do
#     sequence(:title) { |n| "Rating Title #{n}" }
#     sequence(:description) { |n| "Description #{n}" }
#     sequence(:score, (1..5).cycle) { |n| "#{n}" }
#     active { true }
#   end
#
#   factory :inactive_rating, parent: :rating do
#     sequence(:title) { |n| "Inactive Rating Title #{n}" }
#     active { false }
#   end
#
#   factory :invalid_rating, parent: :rating do
#     sequence(:title) { |n| "INVALID Rating Title #{n}" }
#     sequence(:score, (6..7).cycle) { |n| "#{n}" }
#   end
# end
