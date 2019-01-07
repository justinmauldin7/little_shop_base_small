class Rating < ApplicationRecord
  belongs_to :item
  belongs_to :user

  validates_presence_of :title, :description, :active
  validates :score, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5
  }

  def disable
    update_column(:active, false)
  end
end
