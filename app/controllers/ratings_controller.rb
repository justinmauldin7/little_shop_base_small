class RatingsController < ApplicationController
  def new
    @item = Item.find(params[:item_id])
    @rating = Rating.new
  end

  def create
    @rating = Rating.create(user: current_user)
  end

end
