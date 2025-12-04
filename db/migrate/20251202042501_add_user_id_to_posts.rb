class AddUserIdToPosts < ActiveRecord::Migration[6.1]
  def change
    # First add the column as nullable
    add_reference :posts, :user, null: true, foreign_key: true
    
    # Set a default user for existing posts (or create one if none exists)
    default_user = User.first || User.create!(
      email: 'default@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
    
    # Update all existing posts to have the default user
    Post.where(user_id: nil).update_all(user_id: default_user.id)
    
    # Now make it non-nullable
    change_column_null :posts, :user_id, false
  end
end
