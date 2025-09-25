class CreateTestimonials < ActiveRecord::Migration[8.0]
  def change
    create_table :testimonials do |t|
      t.text :quote
      t.string :client_name
      t.string :project
      t.string :company
      t.boolean :featured

      t.timestamps
    end
  end
end
