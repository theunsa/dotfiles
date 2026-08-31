# The author's brand, shown on the landing page and the dossier brand bar.
# Override via ENV; defaults are placeholders to replace before going live.
Rails.application.config.x.brand = {
  name: ENV.fetch("BRAND_NAME", "Theuns Alberts"),
  tagline: ENV.fetch("BRAND_TAGLINE", "I build practical business software, one proven step at a time."),
  contact: ENV.fetch("BRAND_CONTACT", "hello@example.com")
}
