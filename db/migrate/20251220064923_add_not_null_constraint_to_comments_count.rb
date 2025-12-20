class AddNotNullConstraintToCommentsCount < ActiveRecord::Migration[6.1]
  def up
    change_column_null :posts, :comments_count, false
  end

  def down
    change_column_null :posts, :comments_count, true
  end
end
