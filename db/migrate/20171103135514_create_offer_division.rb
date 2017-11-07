class CreateOfferDivision < ActiveRecord::Migration[5.1]
  def change
    create_table :offer_divisions do |t|
      t.integer 'offer_id', null: false
      t.integer 'division_id', null: false

      t.timestamps
    end

    add_index :offer_divisions, [:offer_id]
    add_index :offer_divisions, [:division_id]
  end
end
