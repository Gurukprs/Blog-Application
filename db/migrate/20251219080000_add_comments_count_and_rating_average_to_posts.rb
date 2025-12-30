class AddCommentsCountAndRatingAverageToPosts < ActiveRecord::Migration[6.1]
  def up
    add_column :posts, :comments_count, :integer
    change_column_default :posts, :comments_count, 0
    add_column :posts, :rating_average, :float
  end

  def down
    remove_column :posts, :comments_count
    remove_column :posts, :rating_average
  end
end



