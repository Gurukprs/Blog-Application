class CreateUserCommentRatings < ActiveRecord::Migration[6.1]
  def change
    create_table :user_comment_ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.integer :stars

      t.timestamps
    end
    
    # Ensure a user can only rate a comment once
    add_index :user_comment_ratings, [:user_id, :comment_id], unique: true
  end
end
