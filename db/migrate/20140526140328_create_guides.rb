class CreateGuides < ActiveRecord::Migration
  def change
    create_table :guides do |t|
      t.string :question
      t.text :answer
      t.string :group
      t.string :qtype
      t.integer :score

      t.timestamps
    end
  end
end
