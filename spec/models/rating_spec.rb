require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :score }
    it { should validate_numericality_of(:score).only_integer }
    it { should validate_numericality_of(:score).is_greater_than_or_equal_to(1) }
    it { should validate_numericality_of(:score).is_less_than_or_equal_to(5) }
    it { should validate_presence_of :active }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should belong_to :item }
  end

  # describe 'instance methods' do
  #   it 'can disable a rating' do
  #     user = create(:user)
  #     merchant_1 = create(:merchant)
  #     item_1 = create(:item, user: merchant_1)
  #     yesterday = 1.day.ago
  #     order_1 = create(:completed_order, user: user, created_at: yesterday)
  #     oi_1 = create(:fulfilled_order_item, order: order_1, item: item_1,
  #                   price: 1, quantity: 3, created_at: yesterday,
  #                   updated_at: yesterday)
  #     rating_1 = Rating.create(item_id: item_1, user: user,
  #                               title: "Terrible Product",
  #                               description: "Worst thing I ever bought!",
  #                               score: 1, active: true)
  #     rating_1.save
  #     rating_1.disable
  #     rating_1.save
  #
  #     expect(rating_1.active).to eq(false)
  #     expect(rating_1.active).to_not eq(true)
  #   end
  # end
end
