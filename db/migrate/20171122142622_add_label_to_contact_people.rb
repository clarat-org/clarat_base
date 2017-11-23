class AddLabelToContactPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :contact_people, :label, :string
  end
end
