namespace :dossier do
  # Every user and every dossier belongs to an account, so the tasks below need
  # to know which one. With a single account on the box it is implied; with
  # more than one it has to be named.
  def resolve_account(slug)
    if slug.present?
      Account.find_by(slug: slug) || abort("No account with slug #{slug.inspect}. Accounts: #{Account.pluck(:slug).join(', ')}")
    elsif Account.count == 1
      Account.first
    elsif Account.none?
      abort "No accounts yet. Create one first: rake 'dossier:account[Acme]'"
    else
      abort "More than one account — name it. Accounts: #{Account.pluck(:slug).join(', ')}"
    end
  end

  desc "Create a tenant account. Usage: rake 'dossier:account[Acme Consulting]'"
  task :account, [ :name ] => :environment do |_, args|
    name = args[:name].to_s.strip
    abort "Usage: rake 'dossier:account[Acme Consulting]'" if name.blank?

    account = Account.new(name: name)
    abort account.errors.full_messages.join(", ") unless account.save

    puts "Created account #{account.name} (#{account.slug})."
    puts "Add its first user: rake 'dossier:user[you@example.com,#{account.slug}]'"
  end

  desc "Create an account's user, or reset its password. Usage: rake 'dossier:user[you@example.com,account-slug]'"
  task :user, [ :email, :account ] => :environment do |_, args|
    require "io/console"

    email = args[:email].to_s.strip
    abort "Usage: rake 'dossier:user[you@example.com,account-slug]'" if email.blank?
    account = resolve_account(args[:account])

    # Prompted, never an argument or ENV var: keeps the password out of shell
    # history, `ps` output and the deploy config. This is also the recovery
    # path — there is no password-reset email in this app.
    #
    # getpass needs a TTY, and `kamal app exec` doesn't always give one, so fall
    # back to a plain read (echoed, but still not in argv) rather than blowing up.
    read = lambda do |prompt|
      if $stdin.tty?
        $stdin.getpass(prompt)
      else
        $stderr.print(prompt)
        $stdin.gets.to_s.chomp
      end
    end

    password = read.call("Password: ")
    confirmation = read.call("Confirm password: ")
    abort "Passwords do not match." unless password == confirmation
    abort "Password must be at least 12 characters." if password.to_s.length < 12

    user = User.find_or_initialize_by(email_address: email)
    existed = user.persisted?
    abort "#{user.email_address} belongs to another account (#{user.account.slug})." if existed && user.account_id != account.id
    user.account = account
    user.password = password
    user.password_confirmation = confirmation

    if user.save
      puts existed ? "Password reset for #{user.email_address}." : "Created #{account.slug} user #{user.email_address}."
    else
      abort user.errors.full_messages.join(", ")
    end
  end

  desc "Import a prototype-style markdown file (front matter + body) as a Dossier. Usage: rake 'dossier:import[path/to/index.md,account-slug]'"
  task :import, [ :path, :account ] => :environment do |_, args|
    abort "Usage: rake 'dossier:import[path/to/index.md,account-slug]'" if args[:path].blank?
    account = resolve_account(args[:account])

    source = File.read(args[:path])
    front_matter = {}
    body = source
    if source.start_with?("---\n") && (closing = source.index("\n---\n", 4))
      front_matter = YAML.safe_load(source[4...closing]) || {}
      body = source[(closing + 5)..].to_s.lstrip
    end

    # The prototype keeps the slug as the folder name (e.g. content/d/ji4n-acme/index.md).
    folder_slug = File.basename(File.dirname(File.expand_path(args[:path])))

    dossier = account.dossiers.find_or_initialize_by(slug: folder_slug)
    dossier.assign_attributes(
      client_name: front_matter["client"].presence || folder_slug,
      whatsapp_number: front_matter["whatsapp"].to_s.gsub(/\s+/, "").presence,
      whatsapp_text: front_matter["whatsappText"].presence,
      published: false
    )
    dossier.save!

    document = dossier.documents.first || dossier.documents.build
    document.update!(title: front_matter["title"].presence || "Proposal",
                     body_markdown: LegacyBlockConverter.call(body))

    puts "Imported #{args[:path]} → /d/#{dossier.slug} (unpublished — review in admin, then publish)"
  end
end
