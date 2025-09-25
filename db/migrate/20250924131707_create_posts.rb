class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.datetime :published_at
      t.string :author
      t.string :slug
      t.boolean :published

      t.timestamps
    end
  end
end
