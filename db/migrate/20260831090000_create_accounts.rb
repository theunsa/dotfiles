class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :tagline
      t.string :contact_email

      t.timestamps
    end

    add_index :accounts, :slug, unique: true
  end
end
