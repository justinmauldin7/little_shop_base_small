class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  def subtotal
    quantity * price
  end

  def self.oi_this_month
    fulfilled = self.all.where(fulfilled: true)
    fulfilled.map do |oi|
      if oi.updated_at.month == Time.now.month
         oi.id
      end
    end.compact
  end

  def self.oi_last_month
    fulfilled = self.all.where(fulfilled: true)
    fulfilled.map do |oi|
      if oi.updated_at.month == 1.months.ago.month
         oi.id
      end
    end.compact
  end
end
