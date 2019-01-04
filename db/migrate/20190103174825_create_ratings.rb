class CreateRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :ratings do |t|
      t.string :title
      t.string :description
      t.integer :score
      t.boolean :active, default: true
      t.references :item, foreign_key: true
    end
  end
end
