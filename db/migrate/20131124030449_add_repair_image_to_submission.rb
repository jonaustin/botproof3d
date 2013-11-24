class AddRepairImageToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :repair_image, :string
  end
end
