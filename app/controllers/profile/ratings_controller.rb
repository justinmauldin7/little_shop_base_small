class Profile::RatingsController < ApplicationController
  before_action :require_default_user

  def new
    @order = Order.find(params[:order_id])
    @order_item = OrderItem.find(params[:order_item_id])
    @rating = Rating.new
    @form_path = [:profile, @order, @order_item, @rating]
  end

  def create
    @order = Order.find(params[:order_id])
    @item = OrderItem.find(params[:order_item_id]).item

    if @item.ratings.count < 1 && @order.status != "cancelled"
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
        order = Order.find(params[:order_id])
        order_item = OrderItem.find(params[:order_item_id])
        rating = Rating.new
        @form_path = [:profile, order, order_item, rating]
        flash[:error] = "Your rating has not been created."
        render :new
      end
    else
      if @item.ratings.count == 1
        flash[:error] = "You have already rated this item."
      else
        flash[:error] = "Your rating has not been created."
      end
      redirect_to profile_order_path(params[:order_id])
    end
  end

  def disable
    @rating = OrderItem.find(params[:order_item_id]).item.ratings[0]
    @rating.disable
    @rating.save

    flash[:success] = "Your Rating Has Been Disabled."
    redirect_to profile_order_path(params[:order_id])
  end

  private
  def rating_params
    params.require(:rating).permit(:title, :description, :score)
  end

  def require_default_user
    render file: 'errors/not_found', status: 404 unless current_user && current_user.default?
  end
end
