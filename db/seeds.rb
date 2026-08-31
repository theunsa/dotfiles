# Single-author tool: the one admin user comes from ENV.
email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
password = ENV.fetch("ADMIN_PASSWORD", "changeme-now")

user = User.find_or_initialize_by(email_address: email)
user.update!(password: password, password_confirmation: password)
puts "Admin user: #{email}#{" (DEFAULT CREDENTIALS — set ADMIN_EMAIL/ADMIN_PASSWORD)" unless ENV["ADMIN_EMAIL"]}"
