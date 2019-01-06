class Profile::RatingsController < ApplicationController
  def new
    @order = Order.find(params[:order_id])
    @order_item = OrderItem.find(params[:order_item_id])
    @rating = Rating.new
    @form_path = [:profile, @order, @order_item, @rating]
  end

  def create
    @item = OrderItem.find(params[:order_item_id]).item
    @rating = Rating.create(item: @item,
                            user: current_user,
                            title: rating_params[:title],
                            description: rating_params[:description],
                            score: rating_params[:score],
                            active: true)

    if @rating.save
      redirect_to profile_order_path(params[:order_id])
      flash[:success] = "Your rating was created successfully."
    else
      flash[:error] = "Your rating has not been created."
      render :new
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:title, :description, :score)
  end
end
