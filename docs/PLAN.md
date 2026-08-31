# Dossier — Rails Implementation Plan

**Dossier**: a self-hosted web tool for presenting proposals, roadmaps and phase progress to
clients as a single shareable link (opened mostly on a phone, via WhatsApp). Internal tool +
brand builder. If it's ever offered to others it will be free and self-hosted — never a paid
multi-tenant SaaS — so every architectural choice optimises for *stable and simple to run*,
not for scale.

This plan is written to be handed to an AI agent for implementation.

## History and decisions

- **v0 (done)**: a static Nuxt 4 + @nuxt/content prototype, kept in `nuxt-prototype/`.
  It validated the design: mobile-first proposal page, `::steps` / `::callout` / `::faq`
  components, WhatsApp CTA, unguessable-slug security model. Its README documents all of it.
- **Now**: rebuild as a **Rails** app in this repo (at the repo root). The static build hit
  its ceiling — every content change is a git-commit-and-deploy, and the roadmap items that
  matter (passcode gate, "did they open it?", accept button) all need a server.
- **Writebook** (37signals) was considered and rejected as a base — it's shaped for books,
  not per-client spaces — but we copy its *operational* shape deliberately: Rails + SQLite,
  markdown in the database, zero external services, one-command deploy.

Decisions taken with the author (2026-08-30):

| Decision | Choice | Why |
|---|---|---|
| Database | **SQLite** | Rails 8 default; Writebook-proven; zero extra services; backup = one file (Litestream optional). Each self-hoster gets their own instance, so Postgres's concurrency/multi-tenant advantages never apply. Revisit only if a central hosted instance ever exists. |
| Content | **Markdown in DB, edited in an admin UI** | Removes the deploy step per client — this is the main reason to be in Rails. |
| V1 scope | Parity with the prototype **plus** passcode gate, view tracking, accept button | These were the v2 items that justified the rewrite; ship them. |
| Deploy | **Kamal** to the author's VPS | Rails 8 default; also the cleanest story for future self-hosters. |
| UI | ERB partials copied from `../rails-shadcn-ui` | Its stock theme (`css/tokens-default.css`) *is* dossier's theme: Luma style, amber accent, stone base. Copy, never depend. |

> **Corpus note (2026-08-31):** `../rails-shadcn-ui` was rebuilt since this plan was first
> written. It is now **Basecoat-based**: partials use semantic classes (`class="btn"` +
> `data-variant`/`data-size`) over vendored Basecoat CSS/JS (`vendor/basecoat/`), with the
> import chain in `css/app.css` (tailwindcss → basecoat-luma → token block → extras.css).
> There is no `shadcn-bridge.css` and no per-component Tailwind class strings any more.
> Its README ("Using a component") and CLAUDE.md are the authority; where this plan and
> that repo disagree, the repo wins.

## Stack

- **Rails 8.x** (latest stable), Ruby 3.4+
- **SQLite** for everything: primary DB, Solid Queue, Solid Cache, Solid Cable
  (only add Solid Queue/Cable if a feature actually needs them — v1 likely needs none)
- **Hotwire** (Turbo + Stimulus), **Propshaft**, **importmap** — no Node build step in the app
- **Tailwind CSS v4** via `tailwindcss-rails`, importing the `../rails-shadcn-ui` chain:
  vendored Basecoat Luma CSS + the dossier token block (`tokens-default.css`) + `extras.css`
  (copy the import order from its `css/app.css`; its README shows the wiring)
- **Commonmarker** for markdown (GFM, sanitized output)
- **Kamal** for deploy; SQLite file on a persistent volume under `storage/`
- Rails 8 **authentication generator** for the admin session (no Devise)

## Domain model

```
User        # the author; Rails 8 auth generator. Single-user in practice.
Dossier     # one client space
  client_name      string   # "Acme Body Corporate" — shown as "Prepared for …"
  slug             string   # unguessable: 4-char base36 prefix + parameterized name, unique
  whatsapp_number  string   # E.164, powers the CTA
  whatsapp_text    string   # optional prefill override
  passcode_digest  string   # optional; bcrypt via has_secure_password-style helper
  published        boolean  # unpublished dossiers 404 publicly
Document    # a page within a dossier (v1 UI treats the first as *the* page)
  dossier_id, title, body_markdown, position, slug
Visit       # view tracking, deliberately minimal (POPIA: no raw IPs)
  dossier_id, viewed_at, user_agent (truncated), ip_hash (salted digest)
Acceptance  # the accept button's record
  dossier_id, label ("Step 1 — Discovery"), name (optional free text), accepted_at
```

`Document` exists from day one (proposal now, `status` page later) but v1 admin and public
UI only ever show one document per dossier. No positions UI, no reordering — just the schema.

## Routes

```
GET  /                      # brand landing page (3 lines: name, tagline, contact)
GET  /d/:slug               # public dossier page (published only; 404 otherwise)
GET  /d/:slug/unlock        # passcode form (only when dossier has a passcode)
POST /d/:slug/unlock        # checks passcode, stores unlock in session
POST /d/:slug/acceptances   # the accept button
# --- authenticated ---
GET  /admin                 # dossier list: title, client, views count, last viewed, accepted?
CRUD /admin/dossiers        # form: fields + one big markdown textarea + preview
GET  /admin/dossiers/:id    # per-dossier detail: visits list, acceptances, public link + copy button
POST /session, etc.         # Rails 8 auth generator routes
```

## Build order

Status 2026-08-31: steps 1 and 3–10 are **built and tested** (43 tests green); every view
uses placeholder markup with a comment naming the partial that should replace it. Step 2
(theme + partials) is **next**. Still open: the admin preview toggle (step 9 — form is a
plain textarea so far), the system test (step 12), and step 11 (Kamal config generated but
untuned). Step 8's either/or was decided: the accept button renders via an `::accept`
block in the markdown (`{label="…"}`), no dossier flag.

1. **App skeleton** — `rails new` at the repo root (SQLite, importmap, propshaft,
   tailwind), run the auth generator, seed the single user from ENV credentials.
   Move `nuxt-prototype/` note into README. `.gitignore` for `storage/*.sqlite3*`.
   *(Done. App module is `DossierApp` — `Dossier` is the model.)*
2. **Theme + partials** — per `../rails-shadcn-ui`'s README "Using a component":
   copy the `css/app.css` import chain into the Tailwind entry, vendor the Basecoat Luma
   CSS (+ only the JS files that copied components actually need), take
   `tokens-default.css` as the dossier token block, and copy only the partials v1 uses
   (expected: button, card, alert, accordion/details, input, label, badge, separator,
   table) into `app/views/components/` with a `SOURCE.md` manifest recording the source
   commit. Copied partials belong to this app now and may be trimmed. Then restyle the
   placeholder views (each carries a comment naming its target partial): `markdown/_steps`,
   `_callout`, `_faq`, `_accept`, `shared/_brand_bar`, `dossiers/_whatsapp_cta`, the unlock
   page, and the admin views. Dark mode is a `.dark` class on `<html>`.
3. **Models + migrations** as above. Slug generation on Dossier create
   (`SecureRandom.alphanumeric(4).downcase + "-" + client_name.parameterize`).
4. **Markdown pipeline** — Commonmarker with sanitization, plus a small pre-pass that
   recognises the prototype's three MDC blocks and renders them via ERB partials:
   - `::steps` → step cards with price line (card partial)
   - `::callout` → reassurance callout (alert partial)
   - `::faq` → collapsible Q&A (`<details>`-based accordion partial)
   Keeping the exact `::name … ::` syntax means the prototype's content pastes in
   unchanged. Implement as one PORO (`MarkdownRenderer`) with unit tests; unknown
   `::blocks` render as a visible "unknown block" box rather than silently vanishing.
5. **Public dossier page** — port the prototype's design (mobile-first, ~65ch measure,
   brand bar, end-of-page CTA card + sticky bottom WhatsApp bar below `sm`). Meta:
   `noindex, nofollow, noarchive, noimageindex` + `X-Robots-Tag` header; `robots.txt`
   disallows `/d/`. Unpublished → 404.
6. **Passcode gate** — if `passcode_digest` present and session not unlocked, redirect to
   the unlock form. Plain form, bcrypt check, session flag per dossier. Rate-limit with
   Rails 8's `rate_limit` on the controller.
7. **View tracking** — `after_action` on the public show: record a Visit (skip when an
   admin session is active). Collapse repeat hits: don't record if the same session viewed
   within 30 minutes. Show count + last-viewed in admin.
8. **Accept button** — optional per-dossier (render only when the markdown contains an
   `::accept` block or a dossier flag is set — pick the simpler at build time and note it).
   POST creates an Acceptance, page re-renders with a "Accepted ✓ on {date}" state.
   No email in v1; the author checks admin, and WhatsApp is the real channel anyway.
9. **Admin** — list + form. Editor is a plain `<textarea>` with a Turbo-frame "Preview"
   toggle that round-trips through the real renderer. No JS editor libraries.
10. **Import + first content** — a small `rake dossier:import[path]` that reads a
    prototype-style markdown file (front matter + body) into a Dossier + Document; use it
    to bring in `nuxt-prototype/content/d/ji4n-managing-agent/index.md`.
11. **Kamal deploy** — `config/deploy.yml` for the author's VPS behind existing
    Caddy/Traefik; persistent volume for `storage/`; `bin/backup` = `sqlite3 .backup` +
    scp/rclone (Litestream noted as an upgrade, not installed by default). Document
    self-hosting in the README (env vars: admin credentials, host, secret key).
12. **Tests** — minitest: MarkdownRenderer unit tests, passcode-gate and accept-button
    controller tests, one system test walking the happy path (create dossier in admin →
    open public page → accept).

Acceptance check: the author can (a) log in and create a dossier by pasting markdown,
(b) send `https://domain/d/slug` on WhatsApp and it looks excellent on a 390px phone,
(c) see in admin that the client opened it, (d) optionally require a passcode, and
(e) see an acceptance recorded when the client taps accept — with nothing running on the
VPS beyond the app container.

## Explicitly NOT in v1

- Client logins / magic links (passcode is the ceiling)
- Email notifications, PDF export, file attachments
- Multiple visible documents per dossier (schema yes, UI no)
- WYSIWYG or JS markdown editors
- External analytics, error trackers, or any third-party service
- Multi-tenancy of any kind — one instance, one author

## Later (v2+)

- `status` document per dossier + phase-timeline block (`::timeline`) — retainer visibility
- Multiple documents surfaced with simple nav
- Email/WhatsApp ping to the author on first view and on acceptance
- File attachments (Active Storage, local disk)
- Litestream replication as the documented backup upgrade

## Implementation notes for the agent

- Copy UI from `../rails-shadcn-ui` (see its CLAUDE.md); copies are ours to modify, and the
  app must never reference that repo at runtime.
- The Nuxt prototype in `nuxt-prototype/` is the design reference — match its public page
  look and its markdown authoring format rather than inventing new ones.
- Keep the controller count low; no service objects beyond `MarkdownRenderer`.
- Total effort target: **two to three focused days**. When a decision threatens that
  budget, choose the simpler option and record it in the README's "Decisions" section,
  as the prototype did.
