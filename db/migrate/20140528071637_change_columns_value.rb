class ChangeColumnsValue < ActiveRecord::Migration
  def up
  	change_column :guides, :score, :integer, :default => 0
  	change_column :guides, :learned, :integer, :default => 0
  end

  def down
  	change_column :guides, :score, :integer
  	change_column :guides, :learned, :integer
  end
end
