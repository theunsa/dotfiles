# Single-author tool: the one admin user comes from ENV.
#
# In production there is no fallback — a seed run with the vars unset used to
# create a publicly-known admin login on a public box. Fail loudly instead.
if Rails.env.production? && (ENV["ADMIN_EMAIL"].blank? || ENV["ADMIN_PASSWORD"].blank?)
  abort "Refusing to seed: set ADMIN_EMAIL and ADMIN_PASSWORD, or run `bin/rails dossier:user[you@example.com]`."
end

email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
password = ENV.fetch("ADMIN_PASSWORD", "changeme-now")

user = User.find_or_initialize_by(email_address: email)
user.update!(password: password, password_confirmation: password)
puts "Admin user: #{email}#{" (DEVELOPMENT DEFAULTS — set ADMIN_EMAIL/ADMIN_PASSWORD)" unless ENV["ADMIN_EMAIL"]}"
