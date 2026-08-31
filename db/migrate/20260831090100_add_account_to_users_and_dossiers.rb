class AddAccountToUsersAndDossiers < ActiveRecord::Migration[8.1]
  # Only the two top-level tables get an account_id. Documents, visits and
  # acceptances are reachable only through a dossier, so scoping the dossier
  # scopes them too — a second copy of the tenant key would just be one more
  # thing that can drift out of sync.
  def up
    add_reference :users, :account, foreign_key: true
    add_reference :dossiers, :account, foreign_key: true

    backfill_first_account
    change_column_null :users, :account_id, false
    change_column_null :dossiers, :account_id, false
  end

  def down
    remove_reference :dossiers, :account, foreign_key: true
    remove_reference :users, :account, foreign_key: true
  end

  private

  # Everything that exists before this migration belongs to the author who has
  # been running the app single-user, so it all moves into one account.
  def backfill_first_account
    return if select_value("SELECT COUNT(*) FROM users").to_i.zero? &&
              select_value("SELECT COUNT(*) FROM dossiers").to_i.zero?

    name = ENV.fetch("BRAND_NAME", "Default account")
    now = quote(Time.current)

    execute <<~SQL
      INSERT INTO accounts (name, slug, tagline, contact_email, created_at, updated_at)
      VALUES (#{quote(name)}, 'default', #{quote(ENV["BRAND_TAGLINE"].presence)},
              #{quote(ENV["BRAND_CONTACT"].presence)}, #{now}, #{now})
    SQL

    id = select_value("SELECT id FROM accounts WHERE slug = 'default'").to_i
    execute "UPDATE users SET account_id = #{id} WHERE account_id IS NULL"
    execute "UPDATE dossiers SET account_id = #{id} WHERE account_id IS NULL"
  end
end
