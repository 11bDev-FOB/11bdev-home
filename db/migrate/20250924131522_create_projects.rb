class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.text :description
      t.string :tech_stack
      t.text :client_outcome
      t.boolean :featured

      t.timestamps
    end
  end
end
