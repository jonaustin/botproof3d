class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.integer :user_id
      t.string :name
      t.integer :rating
      t.string :orientation
      t.text :description

      t.timestamps
    end
  end
end
