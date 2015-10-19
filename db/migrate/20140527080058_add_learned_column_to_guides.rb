class AddLearnedColumnToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :learned, :integer
  end
end
