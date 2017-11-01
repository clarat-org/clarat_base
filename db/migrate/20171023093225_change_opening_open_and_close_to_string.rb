class ChangeOpeningOpenAndCloseToString < ActiveRecord::Migration[5.1]
  def up
    remove_column :openings, :open
    remove_column :openings, :close

    add_column :openings, :open, :string
    add_column :openings, :close, :string

    Opening.find_each do |opening|
      next if !opening.name || opening.name.include?('appointment')
      match = opening.name.match(/\A\w{3} (\d{2}:\d{2})-(\d{2}:\d{2})\z/)
      open = match[1]
      close = match[2]
      opening.update_column(:open, open) if open
      opening.update_column(:close, close) if close
    end
  end

  def down
    rename_column :openings, :open, :open_string
    rename_column :openings, :close, :close_string

    add_column :openings, :open, :time
    add_column :openings, :close, :time

    Opening.find_each do |opening|
      if opening.open_string
        open = Time.zone.parse('01.01.2000 ' + opening.open_string)
        opening.update_column :open, open
      end

      if opening.close_string
        close = Time.zone.parse('01.01.2000 ' + opening.close_string)
        opening.update_column :close, close
      end
    end

    remove_column :openings, :open_string
    remove_column :openings, :close_string
  end
end
