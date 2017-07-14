class AddIgnoreCrawlerToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :ignored_by_crawler, :boolean, default: false
  end
end
