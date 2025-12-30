class CreatePostsUsersReadStatus < ActiveRecord::Migration[6.1]
  def change
    create_table :posts_users_read_status, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
    end
    
    add_index :posts_users_read_status, [:user_id, :post_id], unique: true
  end
end
