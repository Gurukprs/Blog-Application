class BackfillCommentsCountAndRatingAverageToPosts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    # Backfill comments_count
    safety_assured do
      execute <<-SQL
        UPDATE posts
        SET comments_count = (
          SELECT COUNT(*)
          FROM comments
          WHERE comments.post_id = posts.id
        )
      SQL
    end

    # Backfill rating_average
    safety_assured do
      execute <<-SQL
        UPDATE posts
        SET rating_average = (
          SELECT AVG(stars)
          FROM ratings
          WHERE ratings.post_id = posts.id
        )
      SQL
    end

    # Set comments_count to 0 for posts with no comments (NULL values)
    safety_assured do
      execute <<-SQL
        UPDATE posts
        SET comments_count = 0
        WHERE comments_count IS NULL
      SQL
    end
  end

  def down
    # No rollback needed for backfill
  end
end
