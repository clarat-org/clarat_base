class InstallTrigramSearch < ActiveRecord::Migration
  def up
    if Rails.env.production? || Rails.env.staging? ||
       Rails.configuration.database_configuration[Rails.env]['adapter'] == 'postgresql'
      execute "CREATE EXTENSION pg_trgm;"
    end
  end

  def down
    if Rails.env.production? || Rails.env.staging? ||
       Rails.configuration.database_configuration[Rails.env]['adapter'] == 'postgresql'
      execute "DROP EXTENSION pg_trgm;"
    end
  end
end
