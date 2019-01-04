class Items::RatingsController < ApplicationController
  def new
    @item = Item.find(params[:id])
    @rating = Rating.new
  end
end
