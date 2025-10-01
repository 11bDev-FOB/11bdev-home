class CreateSitrepItems < ActiveRecord::Migration[8.0]
  def change
    create_table :sitrep_items do |t|
      t.string :item_type # 'github' or 'twitter'
      t.string :title
      t.text :content
      t.string :url
      t.string :external_id
      t.datetime :published_at
      t.json :metadata # Additional data like repo name, commit count, etc.
      
      t.timestamps
    end
    
    add_index :sitrep_items, :item_type
    add_index :sitrep_items, :published_at
    add_index :sitrep_items, :external_id, unique: true
  end
end
