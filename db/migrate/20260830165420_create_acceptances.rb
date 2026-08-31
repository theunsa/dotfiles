class CreateAcceptances < ActiveRecord::Migration[8.1]
  def change
    create_table :acceptances do |t|
      t.references :dossier, null: false, foreign_key: true
      t.string :label
      t.string :name
      t.datetime :accepted_at

      t.timestamps
    end
  end
end
