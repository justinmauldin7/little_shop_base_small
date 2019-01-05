class RatingsController < ApplicationController
  def new
    @item = Item.find(params[:item_id])
    @rating = Rating.new
  end

end
