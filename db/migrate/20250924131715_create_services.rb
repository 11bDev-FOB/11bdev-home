class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :title
      t.text :description
      t.string :icon
      t.boolean :featured
      t.string :price_range

      t.timestamps
    end
  end
end
