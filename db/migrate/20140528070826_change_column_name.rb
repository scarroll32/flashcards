class ChangeColumnName < ActiveRecord::Migration
  def up
  	rename_column :guides, :group, :qgroup
  end

  def down
  	rename_column :guides, :qgroup, :group
  end
end
