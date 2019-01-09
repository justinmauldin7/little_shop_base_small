require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :quantity }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  end

  describe 'relationships' do
    it { should belong_to :order }
    it { should belong_to :item }
  end

  describe 'class methods' do
  end

  describe 'instance methods' do
    it '.subtotal' do
      oi = create(:order_item, quantity: 5, price: 3)

      expect(oi.subtotal).to eq(15)
    end
  end

  describe 'helper methods for merchant stats' do
    before :each do
      @user_1 = create(:user, city: 'Denver', state: 'CO')
      @user_2 = create(:user, city: 'NYC', state: 'NY')
      @user_3 = create(:user, city: 'Seattle', state: 'WA')
      @user_4 = create(:user, city: 'Seattle', state: 'FL')

      @merchant_1, @merchant_2, @merchant_3 = create_list(:merchant, 3)
      @item_1 = create(:item, user: @merchant_1)
      @item_2 = create(:item, user: @merchant_2)
      @item_3 = create(:item, user: @merchant_3)

      @order_1 = create(:completed_order, user: @user_1)
      @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: 10.minutes.ago, updated_at: 9.minutes.ago)

      @order_2 = create(:cancelled_order, user: @user_2)
      @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 300, price: 300, created_at: 2.days.ago, updated_at: 1.minutes.ago)

      @order_3 = create(:completed_order, user: @user_3)
      @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 200, price: 200, created_at: 10.minutes.ago, updated_at: 5.minutes.ago)

      @order_4 = create(:completed_order, user: @user_4)
      @oi_4 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 201, price: 200, created_at: 10.minutes.ago, updated_at: 5.minutes.ago)

      @order_5 = create(:cancelled_order, user: @user_1)
      @oi_5 = create(:fulfilled_order_item, item: @item_1, order: @order_5, quantity: 100, price: 100, created_at: 34.days.ago, updated_at: 32.days.ago)

      @order_6 = create(:completed_order, user: @user_2)
      @oi_6 = create(:fulfilled_order_item, item: @item_2, order: @order_6, quantity: 600, price: 300, created_at: 34.days.ago, updated_at: 32.days.ago)

      @order_7 = create(:completed_order, user: @user_3)
      @oi_7 = create(:fulfilled_order_item, item: @item_3, order: @order_7, quantity: 200, price: 200, created_at: 34.days.ago, updated_at: 32.days.ago)

      @order_8 = create(:completed_order, user: @user_4)
      @oi_8 = create(:fulfilled_order_item, item: @item_3, order: @order_8, quantity: 201, price: 200, created_at: 34.days.ago, updated_at: 32.days.ago)
    end
    
    it '.oi_this_month' do
      expect(OrderItem.oi_this_month.count).to eq(4)
      expect(OrderItem.oi_this_month[0]).to eq(@oi_1.id)
      expect(OrderItem.oi_this_month[1]).to eq(@oi_2.id)
      expect(OrderItem.oi_this_month[2]).to eq(@oi_3.id)
      expect(OrderItem.oi_this_month[3]).to eq(@oi_4.id)
    end

    it '.oi_last_month' do
      expect(OrderItem.oi_last_month.count).to eq(4)
      expect(OrderItem.oi_last_month[0]).to eq(@oi_5.id)
      expect(OrderItem.oi_last_month[1]).to eq(@oi_6.id)
      expect(OrderItem.oi_last_month[2]).to eq(@oi_7.id)
      expect(OrderItem.oi_last_month[3]).to eq(@oi_8.id)
    end
  end
end
