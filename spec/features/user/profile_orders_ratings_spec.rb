require 'rails_helper'

include ActionView::Helpers::NumberHelper

describe 'as a registered user' do
  describe 'on the profile orders page' do
    before :each do
      @user = create(:user)
      @admin = create(:admin)

      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)

      @item_1 = create(:item, user: @merchant_1)
      @item_2 = create(:item, user: @merchant_2)

      yesterday = 1.day.ago

      @order_1 = create(:order, status: "completed", user: @user, created_at: yesterday)
      @oi_1 = create(:order_item, order: @order_1, item: @item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
      @oi_2 = create(:fulfilled_order_item, order: @order_1, item: @item_2, price: 2, quantity: 5, created_at: yesterday, updated_at: 2.hours.ago)

      @order_2 = create(:order, status: "pending", user: @user, created_at: yesterday)
      @oi_3 = create(:order_item, order: @order_2, item: @item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
      @oi_4 = create(:fulfilled_order_item, order: @order_2, item: @item_2, price: 2, quantity: 5, created_at: yesterday, updated_at: 2.hours.ago)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it 'can create a new rating for an item' do
      visit profile_order_path(@order_1)

      within "#oitem-#{@oi_1.id}" do
        click_on "Rate this Item"
      end

      expect(current_path).to eq(new_items_ratings_path)
    end
  end
end













# include ActionView::Helpers::NumberHelper

# RSpec.describe 'Profile Orders page', type: :feature do
#   before :each do
#     @user = create(:user)
#     @admin = create(:admin)
#
#     @merchant_1 = create(:merchant)
#     @merchant_2 = create(:merchant)
#
#     @item_1 = create(:item, user: @merchant_1)
#     @item_2 = create(:item, user: @merchant_2)
#   end
#   context 'as a registered user' do
#     describe 'should show a single order show page' do
#       before :each do
#         yesterday = 1.day.ago
#         @order = create(:order, user: @user, created_at: yesterday)
#         @oi_1 = create(:order_item, order: @order, item: @item_1, price: 1, quantity: 3, created_at: yesterday, updated_at: yesterday)
#         @oi_2 = create(:fulfilled_order_item, order: @order, item: @item_2, price: 2, quantity: 5, created_at: yesterday, updated_at: 2.hours.ago)
#       end
#       scenario 'when logged in as user' do
#         @user.reload
#         allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
#         visit profile_order_path(@order)
#       end
#       after :each do
#         expect(page).to have_content("Order ID #{@order.id}")
#         expect(page).to have_content("Created: #{@order.created_at}")
#         expect(page).to have_content("Last Update: #{@order.last_update}")
#         expect(page).to have_content("Status: #{@order.status}")
#         within "#oitem-#{@oi_1.id}" do
#           expect(page).to have_content(@oi_1.item.name)
#           expect(page).to have_content(@oi_1.item.description)
#           expect(page.find("#item-#{@oi_1.item.id}-image")['src']).to have_content(@oi_1.item.image)
#           expect(page).to have_content("Merchant: #{@oi_1.item.user.name}")
#           expect(page).to have_content("Price: #{number_to_currency(@oi_1.price)}")
#           expect(page).to have_content("Quantity: #{@oi_1.quantity}")
#           expect(page).to have_content("Subtotal: #{number_to_currency(@oi_1.price*@oi_1.quantity)}")
#           expect(page).to have_content("Subtotal: #{number_to_currency(@oi_1.price*@oi_1.quantity)}")
#           expect(page).to have_content("Fulfilled: No")
#           expect(page).to have_link("Rate this Item")
#         end
#         within "#oitem-#{@oi_2.id}" do
#           expect(page).to have_content(@oi_2.item.name)
#           expect(page).to have_content(@oi_2.item.description)
#           expect(page.find("#item-#{@oi_2.item.id}-image")['src']).to have_content(@oi_2.item.image)
#           expect(page).to have_content("Merchant: #{@oi_2.item.user.name}")
#           expect(page).to have_content("Price: #{number_to_currency(@oi_2.price)}")
#           expect(page).to have_content("Quantity: #{@oi_2.quantity}")
#           expect(page).to have_content("Subtotal: #{number_to_currency(@oi_2.price*@oi_2.quantity)}")
#           expect(page).to have_content("Fulfilled: Yes")
#           expect(page).to have_link("Rate this Item")
#         end
#         expect(page).to have_content("Item Count: #{@order.total_item_count}")
#         expect(page).to have_content("Total Cost: #{number_to_currency(@order.total_cost)}")
#       end
#     end
#   end
# end
