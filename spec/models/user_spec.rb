require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :orders }
    it { should have_many(:order_items).through(:orders) }
    it { should have_many :ratings }
  end

  describe 'class methods' do
    describe 'merchant stats' do
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
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

        @order_2 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 300, price: 300, created_at: 2.days.ago, updated_at: 1.minute.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 200, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_4 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 201, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)
      end
      it '.top_3_revenue_merchants' do
        expect(User.top_3_revenue_merchants[0]).to eq(@merchant_2)
        expect(User.top_3_revenue_merchants[0].revenue.to_f).to eq(90000.00)
        expect(User.top_3_revenue_merchants[1]).to eq(@merchant_3)
        expect(User.top_3_revenue_merchants[1].revenue.to_f).to eq(80200.00)
        expect(User.top_3_revenue_merchants[2]).to eq(@merchant_1)
        expect(User.top_3_revenue_merchants[2].revenue.to_f).to eq(10000.00)
      end
      it '.merchant_fulfillment_times' do
        expect(User.merchant_fulfillment_times(:asc, 1)).to eq([@merchant_1])
        expect(User.merchant_fulfillment_times(:desc, 2)).to eq([@merchant_2, @merchant_3])
      end
      it '.top_3_fulfilling_merchants' do
        expect(User.top_3_fulfilling_merchants[0]).to eq(@merchant_1)
        aft = User.top_3_fulfilling_merchants[0].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:01:00')
        expect(User.top_3_fulfilling_merchants[1]).to eq(@merchant_3)
        aft = User.top_3_fulfilling_merchants[1].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:05:00')
        expect(User.top_3_fulfilling_merchants[2]).to eq(@merchant_2)
        aft = User.top_3_fulfilling_merchants[2].avg_fulfillment_time
        expect(aft[0..13]).to eq('1 day 23:59:00')
      end
      it '.bottom_3_fulfilling_merchants' do
        expect(User.bottom_3_fulfilling_merchants[0]).to eq(@merchant_2)
        aft = User.bottom_3_fulfilling_merchants[0].avg_fulfillment_time
        expect(aft[0..13]).to eq('1 day 23:59:00')
        expect(User.bottom_3_fulfilling_merchants[1]).to eq(@merchant_3)
        aft = User.bottom_3_fulfilling_merchants[1].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:05:00')
        expect(User.bottom_3_fulfilling_merchants[2]).to eq(@merchant_1)
        aft = User.bottom_3_fulfilling_merchants[2].avg_fulfillment_time
        expect(aft[0..7]).to eq('00:01:00')
      end
    end
  end

  describe 'instance methods' do
    it '.my_pending_orders' do
      merchants = create_list(:merchant, 2)
      item_1 = create(:item, user: merchants[0])
      item_2 = create(:item, user: merchants[1])
      orders = create_list(:order, 3)
      create(:order_item, order: orders[0], item: item_1, price: 1, quantity: 1)
      create(:order_item, order: orders[1], item: item_2, price: 1, quantity: 1)
      create(:order_item, order: orders[2], item: item_1, price: 1, quantity: 1)

      expect(merchants[0].my_pending_orders).to eq([orders[0], orders[2]])
      expect(merchants[1].my_pending_orders).to eq([orders[1]])
    end

    it '.inventory_check' do
      admin = create(:admin)
      user = create(:user)
      merchant = create(:merchant)
      item = create(:item, user: merchant, inventory: 100)

      expect(admin.inventory_check(item.id)).to eq(nil)
      expect(user.inventory_check(item.id)).to eq(nil)
      expect(merchant.inventory_check(item.id)).to eq(item.inventory)
    end

    describe 'merchant stats methods' do
      before :each do
        @user_1 = create(:user, city: 'Springfield', state: 'MO')
        @user_2 = create(:user, city: 'Springfield', state: 'CO')
        @user_3 = create(:user, city: 'Las Vegas', state: 'NV')
        @user_4 = create(:user, city: 'Denver', state: 'CO')

        @merchant = create(:merchant)
        @item_1 = create(:item, user: @merchant, inventory: 100)
        @item_2 = create(:item, user: @merchant, inventory: 200)
        @item_3 = create(:item, user: @merchant, inventory: 300)
        @item_4 = create(:item, user: @merchant, inventory: 400)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1a = create(:fulfilled_order_item, order: @order_1, item: @item_1, quantity: 22, price: 22)

        @order_2 = create(:completed_order, user: @user_1)
        @oi_1b = create(:fulfilled_order_item, order: @order_2, item: @item_1, quantity: 11, price: 11)

        @order_3 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, order: @order_3, item: @item_2, quantity: 55, price: 55)

        @order_4 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, order: @order_4, item: @item_3, quantity: 34, price: 33)

        @order_5 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, order: @order_5, item: @item_4, quantity: 44, price: 44)

      end
      it '.top_items_by_quantity' do
        expect(@merchant.top_items_by_quantity(5)).to eq([@item_2, @item_4, @item_3, @item_1])
      end
      it '.quantity_sold_percentage' do
        expect(@merchant.quantity_sold_percentage[:sold]).to eq(166)
        expect(@merchant.quantity_sold_percentage[:total]).to eq(1166)
        expect(@merchant.quantity_sold_percentage[:percentage]).to eq(14.24)
      end
      it '.top_3_states' do
        expect(@merchant.top_3_states.first.state).to eq('CO')
        expect(@merchant.top_3_states.first.quantity_shipped).to eq(99)
        expect(@merchant.top_3_states.second.state).to eq('NV')
        expect(@merchant.top_3_states.second.quantity_shipped).to eq(34)
        expect(@merchant.top_3_states.third.state).to eq('MO')
        expect(@merchant.top_3_states.third.quantity_shipped).to eq(33)
      end
      it '.top_3_cities' do
        expect(@merchant.top_3_cities.first.city).to eq('Springfield')
        expect(@merchant.top_3_cities.first.state).to eq('CO')
        expect(@merchant.top_3_cities.second.city).to eq('Denver')
        expect(@merchant.top_3_cities.second.state).to eq('CO')
        expect(@merchant.top_3_cities.third.city).to eq('Las Vegas')
        expect(@merchant.top_3_cities.third.state).to eq('NV')
      end
      it '.most_ordering_user' do
        expect(@merchant.most_ordering_user).to eq(@user_1)
        expect(@merchant.most_ordering_user.order_count).to eq(2)
      end
      it '.most_items_user' do
        expect(@merchant.most_items_user).to eq(@user_2)
        expect(@merchant.most_items_user.item_count).to eq(55)
      end
      it '.top_3_revenue_users' do
        expect(@merchant.top_3_revenue_users[0]).to eq(@user_2)
        expect(@merchant.top_3_revenue_users[0].revenue.to_f).to eq(3025.0)
        expect(@merchant.top_3_revenue_users[1]).to eq(@user_4)
        expect(@merchant.top_3_revenue_users[1].revenue.to_f).to eq(1936.0)
        expect(@merchant.top_3_revenue_users[2]).to eq(@user_3)
        expect(@merchant.top_3_revenue_users[2].revenue.to_f).to eq(1122.0)
      end
    end

    describe 'more merchant stats' do
      before :each do
        @user_1 = create(:user, city: 'Denver', state: 'CO')
        @user_2 = create(:user, city: 'NYC', state: 'NY')
        @user_3 = create(:user, city: 'Seattle', state: 'WA')
        @user_4 = create(:user, city: 'Seattle', state: 'FL')

        @merchant_1 = create(:merchant,  city: 'Denver', state: 'CO')
        @merchant_2 = create(:merchant, city: 'Denver', state: 'CO')
        @merchant_3 = create(:merchant)
        @item_1 = create(:item, user: @merchant_1)
        @item_2 = create(:item, user: @merchant_2)
        @item_3 = create(:item, user: @merchant_3)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: 10.minutes.ago, updated_at: 9.minutes.ago)

        @order_2 = create(:cancelled_order, user: @user_1)
        @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 300, price: 300, created_at: 2.days.ago, updated_at: 1.minutes.ago)

        @order_3 = create(:completed_order, user: @user_1)
        @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 200, price: 200, created_at: 10.minutes.ago, updated_at: 5.minutes.ago)

        @order_4 = create(:completed_order, user: @user_1)
        @oi_4 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 201, price: 200, created_at: 10.minutes.ago, updated_at: 5.minutes.ago)

        @order_5 = create(:cancelled_order, user: @user_1)
        @oi_5 = create(:fulfilled_order_item, item: @item_1, order: @order_5, quantity: 100, price: 100, created_at: 34.days.ago, updated_at: 32.days.ago)

        @order_6 = create(:completed_order, user: @user_1)
        @oi_6 = create(:fulfilled_order_item, item: @item_2, order: @order_6, quantity: 600, price: 300, created_at: 34.days.ago, updated_at: 32.days.ago)

        @order_7 = create(:completed_order, user: @user_1)
        @oi_7 = create(:fulfilled_order_item, item: @item_3, order: @order_7, quantity: 200, price: 200, created_at: 34.days.ago, updated_at: 32.days.ago)

        @order_8 = create(:completed_order, user: @user_1)
        @oi_8 = create(:fulfilled_order_item, item: @item_3, order: @order_8, quantity: 201, price: 200, created_at: 34.days.ago, updated_at: 32.days.ago)
      end
      it 'top 10 merchants who sold most items THIS month' do
        expect(User.top_merchants_sold_most_items_this_month(3)[0]).to eq(@merchant_3)
        expect(User.top_merchants_sold_most_items_this_month(3)[1]).to eq(@merchant_2)
        expect(User.top_merchants_sold_most_items_this_month(3)[2]).to eq(@merchant_1)
      end
      it 'top 10 merchants who sold most items LAST month' do
        expect(User.top_merchants_sold_most_items_last_month(3)[0]).to eq(@merchant_2)
        expect(User.top_merchants_sold_most_items_last_month(3)[1]).to eq(@merchant_3)
        expect(User.top_merchants_sold_most_items_last_month(3)[2]).to eq(@merchant_1)
      end
      it 'top 10 merchants who fulfilled non-cancelled orders THIS month' do
        expect(User.top_merchants_with_non_cancelled_orders_this_month(3)[0]).to eq(@merchant_3)
        expect(User.top_merchants_with_non_cancelled_orders_this_month(3)[1]).to eq(@merchant_1)
      end
      it 'top 10 merchants who fulfilled non-cancelled orders LAST month' do
        expect(User.top_merchants_with_non_cancelled_orders_last_month(3)[0]).to eq(@merchant_3)
        expect(User.top_merchants_with_non_cancelled_orders_last_month(3)[1]).to eq(@merchant_2)
      end
      it 'top 5 merchants who fulfilled fastest to my state' do
        login_user = create(:user, city: 'Denver', state: 'CO')

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(login_user)

        expect(login_user.top_fulfilling_merchants_in_my_state(login_user, 3)[0]).to eq(@merchant_1)
        expect(login_user.top_fulfilling_merchants_in_my_state(login_user, 3)[1]).to eq(@merchant_2)
      end
      it 'top 5 merchants who fulfilled fastest to my city' do
        login_user = create(:user, city: 'Denver', state: 'CO')

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(login_user)

        expect(login_user.top_fulfilling_merchants_in_my_city(login_user, 3)[0]).to eq(@merchant_1)
        expect(login_user.top_fulfilling_merchants_in_my_city(login_user, 3)[1]).to eq(@merchant_2)
      end
    end
  end
end
