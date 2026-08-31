rails-shadcn-ui @ dca3b15 (basecoat 6953a4a)
accordion, alert, badge, button, card, input, label, separator, table — copied 2026-08-31

No JS vendored: every partial copied here is native/static (accordion uses
`<details name="...">` for single-open, needing no script). If a future
component needs `vendor/basecoat/js/*`, copy it into `vendor/basecoat/js/`
alongside the CSS already vendored under `vendor/basecoat/css/`.

Re-copying is the upgrade path:
  git -C ../rails-shadcn-ui log dca3b15..HEAD -- components/button/
