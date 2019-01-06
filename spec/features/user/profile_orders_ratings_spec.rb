require 'rails_helper'

include ActionView::Helpers::NumberHelper

describe 'as a visitor' do
  describe 'on the profile orders page' do
    it 'can create a new rating for an item' do
      user = create(:user)
      merchant_1 = create(:merchant)
      item_1 = create(:item, user: merchant_1)
      yesterday = 1.day.ago
      order_1 = create(:completed_order, user: user, created_at: yesterday)
      oi_1 = create(:fulfilled_order_item, order: order_1, item: item_1,
                    price: 1, quantity: 3, created_at: yesterday,
                    updated_at: yesterday)
      rating_1 = Rating.create(item_id: item_1, user: user,
                                title: "Terrible Product",
                                description: "Worst thing I ever bought!",
                                score: 1, active: true)

      visit profile_order_path(order_1)

      within "#oitem-#{oi_1.id}" do
        click_on "Rate this Item"
      end

      expect(page.status_code).to eq(404)
      end

  end
end

describe 'as a registered user' do
  describe 'on the profile orders page' do
    before :each do
      @user = create(:user)
      @admin = create(:admin)

      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)

      @item_1 = create(:item, user: @merchant_1)
      @item_2 = create(:item, user: @merchant_2)

      @yesterday = 1.day.ago

      @order_1 = create(:completed_order, user: @user, created_at: @yesterday)
      @oi_1 = create(:fulfilled_order_item, order: @order_1, item: @item_1,
                      price: 1, quantity: 3, created_at: @yesterday,
                      updated_at: @yesterday)
      @oi_2 = create(:fulfilled_order_item, order: @order_1, item: @item_2,
                     price: 2, quantity: 5, created_at: @yesterday,
                     updated_at: 2.hours.ago)

      @cancelled_order = create(:cancelled_order, user: @user, created_at: @yesterday)
      @oi_3 = create(:order_item, order: @cancelled_order, item: @item_1, price: 1,
                     quantity: 3, created_at: @yesterday, updated_at: @yesterday)
      @oi_4 = create(:fulfilled_order_item, order: @cancelled_order, item: @item_2,
                     price: 2, quantity: 5, created_at: @yesterday,
                     updated_at: 2.hours.ago)

      @rating_1 = Rating.create(item_id: @item_1, user: @user,
                                title: "Terrible Product",
                                description: "Worst thing I ever bought!",
                                score: 1, active: true)
      @rating_2 = Rating.create(item_id: @item_1, user: @user,
                                title: "Great Product",
                                description: "Best thing I ever bought!",
                                score: 5, active: true)
      @rating_inactive = Rating.create(item_id: @item_1, user: @user,
                                       title: "Terrible Product",
                                       description: "Worst thing I ever bought!",
                                       score: 1, active: false)
      @rating_invalid = Rating.create(item_id: @item_1, user: @user,
                                      title: "Terrible Product",
                                      description: "Worst thing I ever bought!",
                                      score: 7, active: true)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
    end

    it 'can create a new rating for an item' do
      visit profile_order_path(@order_1)

      within "#oitem-#{@oi_1.id}" do
        click_on "Rate this Item"
      end

      expect(current_path).to eq(profile_order_new_order_item_rating_path(@order_1, @oi_1))

      fill_in :rating_title, with: @rating_1.title
      fill_in :rating_description, with: @rating_1.description
      fill_in :rating_score, with: @rating_1.score

      click_on "Create Rating"

      expect(current_path).to eq(profile_order_path(@order_1))

      within "#oitem-#{@oi_1.id}" do
        expect(page).to_not have_link("Rate this Item")
        expect(page).to have_content("Item Rating:")
        expect(page).to have_content("Rating Title: #{@rating_1.title}")
        expect(page).to have_content("Rating Description: #{@rating_1.description}")
        expect(page).to have_content("Rating Score: #{@rating_1.score}")
      end
    end

    it 'cannot create a second rating for an item' do
      visit profile_order_path(@order_1)

      within "#oitem-#{@oi_1.id}" do
        click_on "Rate this Item"
      end

      fill_in :rating_title, with: @rating_1.title
      fill_in :rating_description, with: @rating_1.description
      fill_in :rating_score, with: @rating_1.score

      click_on "Create Rating"

      visit profile_order_new_order_item_rating_path(@order_1, @oi_1)

      expect(current_path).to eq(profile_order_new_order_item_rating_path(@order_1, @oi_1))

      fill_in :rating_title, with: @rating_2.title
      fill_in :rating_description, with: @rating_2.description
      fill_in :rating_score, with: @rating_2.score

      click_on "Create Rating"

      expect(current_path).to eq(profile_order_path(@order_1))

      expect(page).to have_content("You have already rated this item.")

      within "#oitem-#{@oi_1.id}" do
        expect(@oi_1.item.ratings.count).to eq(1)

        expect(page).to_not have_link("Rate this Item")
        expect(page).to have_content("Item Rating:")
        expect(page).to have_content("Rating Title: #{@rating_1.title}")
        expect(page).to have_content("Rating Description: #{@rating_1.description}")
        expect(page).to have_content("Rating Score: #{@rating_1.score}")

        expect(page).to_not have_content("Rating Title: #{@rating_2.title}")
        expect(page).to_not have_content("Rating Description: #{@rating_2.description}")
        expect(page).to_not have_content("Rating Score: #{@rating_2.score}")
      end
    end

    it 'only allows a score of 1-5 when creating rating' do
      visit profile_order_path(@order_1)

      within "#oitem-#{@oi_1.id}" do
        click_on "Rate this Item"
      end

      expect(current_path).to eq(profile_order_new_order_item_rating_path(@order_1, @oi_1))

      fill_in :rating_title, with: @rating_invalid.title
      fill_in :rating_description, with: @rating_invalid.description
      fill_in :rating_score, with: @rating_invalid.score

      click_on "Create Rating"

      expect(current_path).to eq(profile_order_order_item_ratings_path(@order_1, @oi_1))

      expect(page).to have_content("Your rating has not been created.")
      expect(@oi_1.item.ratings.count).to eq(0)
    end

    it 'cannot leave review for canceled order' do
      visit profile_order_path(@cancelled_order)

      within "#oitem-#{@oi_3.id}" do
        expect(page).to_not have_link("Rate this Item")
      end

      within "#oitem-#{@oi_4.id}" do
        expect(page).to_not have_link("Rate this Item")
      end

      visit profile_order_new_order_item_rating_path(@cancelled_order, @oi_3)

      expect(current_path).to eq(profile_order_new_order_item_rating_path(@cancelled_order, @oi_3))

      fill_in :rating_title, with: @rating_1.title
      fill_in :rating_description, with: @rating_1.description
      fill_in :rating_score, with: @rating_1.score

      click_on "Create Rating"

      expect(current_path).to eq(profile_order_path(@cancelled_order))

      expect(page).to have_content("Your rating has not been created.")
      expect(@oi_3.item.ratings.count).to eq(0)
    end

    it 'can disable a review for an item' do
      visit profile_order_path(@order_1)

      within "#oitem-#{@oi_1.id}" do
        click_on "Rate this Item"
      end

      fill_in :rating_title, with: @rating_1.title
      fill_in :rating_description, with: @rating_1.description
      fill_in :rating_score, with: @rating_1.score

      click_on "Create Rating"
      within "#oitem-#{@oi_1.id}" do
        expect(page).to have_button("Disable Your Review")
        click_button "Disable Your Review"
      end

      expect(current_path).to eq(profile_order_path(@corder_1))
      expect(page).to have_content("Your Review Has Been Disabled.")
      expect(@oi_3.item.ratings.active).to eq(false)

      within "#oitem-#{@oi_1.id}" do
        expect(page).to_not have_button("Disable Your Review")
      end
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
