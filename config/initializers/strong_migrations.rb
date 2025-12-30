# Mark existing migrations as safe
# Only configure if strong_migrations is available (development environment)
if defined?(StrongMigrations)
  # Mark all existing migrations as safe (they were created before strong_migrations was added)
  StrongMigrations.start_after = 20251113034156

  # Set timeouts for migrations
  StrongMigrations.lock_timeout = 10.seconds
  StrongMigrations.statement_timeout = 1.hour

  # Analyze tables after indexes are added
  # Outdated statistics can sometimes hurt performance
  StrongMigrations.auto_analyze = true

# Set the version of the production database
# so the right checks are run in development
# StrongMigrations.target_version = 10

  # Add custom checks
  # StrongMigrations.add_check do |method, args|
  #   if method == :add_index && args[0].to_s == "users"
  #     stop! "No more indexes on the users table"
  #   end
  # end
end
