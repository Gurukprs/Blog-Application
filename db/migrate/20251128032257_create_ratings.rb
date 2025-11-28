class CreateRatings < ActiveRecord::Migration[6.1]
  def change
    create_table :ratings do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :stars

      t.timestamps
    end
  end
end
