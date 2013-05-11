class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.string :name
      t.integer :point
      t.integer :magnification
      t.string :difficulty

      t.timestamps
    end
  end
end
