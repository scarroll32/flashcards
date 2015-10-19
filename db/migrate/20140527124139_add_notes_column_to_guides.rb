class AddNotesColumnToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :notes, :text
  end
end
