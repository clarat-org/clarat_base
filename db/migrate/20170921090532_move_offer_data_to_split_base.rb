class MoveOfferDataToSplitBase < ActiveRecord::Migration
  def change
    add_column :split_bases, :code_word, :string, limit: 140
    remove_column :offers, :expires_at, :date
  end

  # TODO: after filling fields create migration with:
  # remove_column :offers, :code_word, :string, limit: 140
  # remove_column :offers, :solution_category_id, :integer
end
