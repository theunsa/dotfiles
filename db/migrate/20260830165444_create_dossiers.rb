class CreateDossiers < ActiveRecord::Migration[8.1]
  def change
    create_table :dossiers do |t|
      t.string :client_name
      t.string :slug
      t.string :whatsapp_number
      t.string :whatsapp_text
      t.string :passcode_digest
      t.boolean :published

      t.timestamps
    end
    add_index :dossiers, :slug, unique: true
  end
end
