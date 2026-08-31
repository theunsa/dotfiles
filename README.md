# Dossier

Self-hosted client spaces: proposals, roadmaps and phase progress as a single
shareable link (`/d/<client-slug>`), sent via WhatsApp, opened on a phone.

A **Rails 8 + SQLite** app at this repo's root — see **`docs/PLAN.md`** for the
plan and the decisions behind it.

- `nuxt-prototype/` — the validated static prototype (design reference; its
  README documents how it works)
- `docs/first-client-proposal-draft.md` — content for the first client dossier

## Running it

```sh
bin/setup          # bundle, prepare the database, seed the dev admin user
bin/dev            # http://localhost:3000 — /admin is the author's side
bin/rails test
```

The dev seed creates `admin@example.com` / `changeme-now`. That fallback exists
only in development; seeding in production without credentials aborts.

## The admin user

One instance, one author — so there is no sign-up page and no password-reset
email. Both would be attack surface on an admin panel with exactly one user, and
a reset email would put an SMTP provider on the login path of an app whose whole
point is depending on no external services.

Create the user, or recover a forgotten password, on the box:

```sh
bin/rails 'dossier:user[you@example.com]'   # prompts for the password twice
```

The password is prompted, never passed as an argument, so it stays out of shell
history, `ps` output and the deploy config. Running it for an existing email
resets that user's password.

For an unattended first boot, `bin/rails db:seed` reads `ADMIN_EMAIL` and
`ADMIN_PASSWORD` instead.

Sign-in is email + password (Rails 8's authentication generator: `authenticate_by`,
rate-limited, real session rows you can revoke). The session cookie is permanent,
so it's one sign-in per device.

## Multiple clients, one author

A `Dossier` is one client's space, and there is no limit on how many you create.
There is no multi-tenancy in the other sense: no second author, no organizations,
no per-tenant scoping. Another consultant who wants this runs their own copy.

## Environment

| Variable | Used for | Default |
|---|---|---|
| `ADMIN_EMAIL`, `ADMIN_PASSWORD` | unattended `db:seed` provisioning | dev-only fallback |
| `BRAND_NAME`, `BRAND_TAGLINE`, `BRAND_CONTACT` | landing page and dossier brand bar | placeholders |
| `SECRET_KEY_BASE` | Rails; also salts the visit IP hashes | — |

Changing `SECRET_KEY_BASE` re-salts `Visit#ip_hash`, so old visits stop
correlating with new ones. Counts and timestamps are unaffected.

## Writing a dossier

The editor is a plain textarea with two aids above it:

- **Insert chips** (Steps / Callout / FAQ / Accept) drop a filled-in starter block
  at the cursor and select its example text so you can type straight over it.
  Snippets live in `MarkdownRenderer::SNIPPETS`, beside the parser that reads
  them, and a test asserts each one still renders as the block it claims to be.
- **Edit / Preview** renders the unsaved markdown through the same
  `MarkdownRenderer` the client's page uses, so the preview can't drift from the
  real thing. An `::accept` button previews as disabled — a live one would record
  an acceptance the client never made.

Both are progressive enhancement: with JavaScript off the textarea still works,
the chips just do nothing.

## Importing prototype content

```sh
bin/rails 'dossier:import[nuxt-prototype/content/d/ji4n-managing-agent/index.md]'
```

Imports as an **unpublished** dossier — review it in `/admin`, then publish.
Unpublished dossiers 404 publicly.

## Deploy

Kamal to a VPS (`config/deploy.yml`); the SQLite files live on a persistent
volume under `storage/`. Back up with `sqlite3 .backup`; Litestream is a
documented upgrade, not a dependency.
