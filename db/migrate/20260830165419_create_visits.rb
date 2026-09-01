class CreateVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :visits do |t|
      t.references :brief, null: false, foreign_key: true
      t.datetime :viewed_at
      t.string :user_agent
      t.string :ip_hash

      t.timestamps
    end
  end
end
