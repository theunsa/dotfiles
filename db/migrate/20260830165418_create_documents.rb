class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.references :brief, null: false, foreign_key: true
      t.string :title
      t.string :slug
      t.text :body_markdown
      t.integer :position

      t.timestamps
    end
  end
end
