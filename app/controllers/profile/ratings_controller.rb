class Profile::RatingsController < ApplicationController
  def new
    @order = Order.find(params[:order_id])
    @order_item = OrderItem.find(params[:order_item_id])
    @rating = Rating.new
    @form_path = [:profile, @order, @order_item, @rating]
  end

  # def create
  #   @rating = Rating.create(user: current_user)
  #   binding.pry
  #   redirect_to profile_order_path(params[:order_id])
  #   flash[:success] = "Your item rating was created successfully"
  # end

end
