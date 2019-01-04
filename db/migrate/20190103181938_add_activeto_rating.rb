class AddActivetoRating < ActiveRecord::Migration[5.1]
  def change
    add_column :ratings, :active, :boolean, default: true
  end
end
