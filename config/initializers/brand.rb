# The app's own brand: what the landing page and sign-in screen show, and what
# an account falls back to for any branding field it has left blank. A tenant's
# own brand lives on its Account record — see the `brand` view helper.
# Override via ENV; defaults are placeholders to replace before going live.
Rails.application.config.x.brand = {
  name: ENV.fetch("BRAND_NAME", "Theuns Alberts"),
  tagline: ENV.fetch("BRAND_TAGLINE", "I build practical business software, one proven step at a time."),
  contact: ENV.fetch("BRAND_CONTACT", "hello@example.com")
}
