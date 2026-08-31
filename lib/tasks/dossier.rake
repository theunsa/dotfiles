namespace :dossier do
  desc "Import a prototype-style markdown file (front matter + body) as a Dossier. Usage: rake 'dossier:import[path/to/index.md]'"
  task :import, [ :path ] => :environment do |_, args|
    abort "Usage: rake 'dossier:import[path/to/index.md]'" if args[:path].blank?

    source = File.read(args[:path])
    front_matter = {}
    body = source
    if source.start_with?("---\n") && (closing = source.index("\n---\n", 4))
      front_matter = YAML.safe_load(source[4...closing]) || {}
      body = source[(closing + 5)..].to_s.lstrip
    end

    # The prototype keeps the slug as the folder name (e.g. content/d/ji4n-acme/index.md).
    folder_slug = File.basename(File.dirname(File.expand_path(args[:path])))

    dossier = Dossier.find_or_initialize_by(slug: folder_slug)
    dossier.assign_attributes(
      client_name: front_matter["client"].presence || folder_slug,
      whatsapp_number: front_matter["whatsapp"].to_s.gsub(/\s+/, "").presence,
      whatsapp_text: front_matter["whatsappText"].presence,
      published: false
    )
    dossier.save!

    document = dossier.documents.first || dossier.documents.build
    document.update!(title: front_matter["title"].presence || "Proposal", body_markdown: body)

    puts "Imported #{args[:path]} → /d/#{dossier.slug} (unpublished — review in admin, then publish)"
  end
end
