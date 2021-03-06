class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.string :permalink
      t.integer :priority
      t.string :category
      t.text :content
      t.text :md_content

      t.timestamps
    end
    add_index :pages, :permalink
  end
end
