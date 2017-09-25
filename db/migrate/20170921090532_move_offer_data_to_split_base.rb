class MoveOfferDataToSplitBase < ActiveRecord::Migration
  def change
    add_column :split_bases, :code_word, :string, limit: 140
    rename_column :offers, :expires_at, :ends_at
    change_column :offers, :ends_at, :date, null: true
  end

  # TODO: after filling fields create migration with:
  # remove_column :offers, :code_word, :string, limit: 140
  # remove_column :offers, :solution_category_id, :integer
end
