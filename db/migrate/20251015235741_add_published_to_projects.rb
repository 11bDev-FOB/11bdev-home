class AddPublishedToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :published, :boolean, default: true
  end
end
