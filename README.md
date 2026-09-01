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

There is no sign-up page and no password-reset email. Both would be attack
surface on an admin panel with a handful of users, and a reset email would put an
SMTP provider on the login path of an app whose whole point is depending on no
external services. Users are made on the box.

Create a user, or recover a forgotten password:

```sh
bin/rails 'dossier:user[you@example.com,account-slug]'   # prompts for the password twice
```

The account may be left off while there is only one on the box; with more than
one it has to be named.

The password is prompted, never passed as an argument, so it stays out of shell
history, `ps` output and the deploy config. Running it for an existing email
resets that user's password.

For an unattended first boot, `bin/rails db:seed` reads `ADMIN_EMAIL` and
`ADMIN_PASSWORD` instead, and puts that user in a `default` account.

Sign-in is email + password (Rails 8's authentication generator: `authenticate_by`,
rate-limited, real session rows you can revoke). The session cookie is permanent,
so it's one sign-in per device.

## Accounts (tenancy)

Two levels, easy to confuse:

- A **Dossier** is one *client's* space — the page you send someone.
- An **Account** is one *customer of this app*: another consultant, with their
  own users and their own dossiers, sharing the same instance.

Tenancy is **row-based**: one SQLite database for everyone, separated by
`account_id`, not a database file per customer. A file per tenant would mean N
migration runs, N backups and connection switching for every request, and it
would make any cross-account query (billing, totals, an operator dashboard)
impossible — all to buy isolation that a scoped query already gives. It also
keeps the door open: row-based scoping is database-agnostic, so if SQLite is
ever outgrown, only the adapter changes.

Only `users` and `dossiers` carry `account_id`. Documents and visits hang off a
dossier, so scoping the dossier scopes them too; a second copy of the tenant key
would only be one more thing that can drift.

Where the tenant comes from:

- **Admin** — from the signed-in user (`Current.account`). Every admin
  controller reaches records through `Admin::BaseController#dossiers`, so a query
  that forgets the tenant is a `NoMethodError`, not a leak. Another account's
  slug 404s.
- **Public `/d/:slug`** — from the dossier itself. Slugs are globally unique and
  unguessable, so a client needs only the link, never the account it belongs to.
  The dossier then decides whose brand the page wears.

A user signed in to one account gets no privileges over another's dossiers: no
draft preview, no passcode bypass, and their views count as visits.

Each account brands its own pages (`name`, `tagline`, `contact_email`); anything
left blank falls back to the instance-wide `BRAND_*` values, which are also what
the landing page shows.

```sh
bin/rails 'dossier:account[Acme Consulting]'                 # new tenant
bin/rails 'dossier:user[them@acme.com,acme-consulting]'       # its first user
```

There is still no sign-up page — accounts are created on the box, on purpose.

## Environment

| Variable | Used for | Default |
|---|---|---|
| `ADMIN_EMAIL`, `ADMIN_PASSWORD` | unattended `db:seed` provisioning | dev-only fallback |
| `BRAND_NAME`, `BRAND_TAGLINE`, `BRAND_CONTACT` | landing page, and the fallback for an account's own branding | placeholders |
| `SECRET_KEY_BASE` | Rails; also salts the visit IP hashes | — |

Changing `SECRET_KEY_BASE` re-salts `Visit#ip_hash`, so old visits stop
correlating with new ones. Counts and timestamps are unaffected.

## Writing a dossier

A dossier body is one markdown document. Plain GFM (headings, lists, tables,
code, quotes) renders as prose; the special sections are fenced code blocks
whose language is a block name, holding YAML:

````markdown
```callout
title: You only commit to Step 1
body: Every step is priced **before** it starts.
```
````

Blocks: `steps`, `callout`, `faq`. Because a fence is standard
CommonMark, the document survives any other markdown tool — elsewhere the
blocks just show as highlighted YAML. Any other fence language (` ```ruby `)
renders as an ordinary code block. A block whose YAML won't parse renders a
visible error box, never nothing.

The editor is a plain textarea with a live preview beside it:

- **Insert chips** (Steps / Callout / FAQ) drop a filled-in starter block
  at the cursor and select its example text so you can type straight over it.
  Snippets live in `MarkdownRenderer::SNIPPETS`, beside the parser that reads
  them, and a test asserts each one still renders as the block it claims to be.
- **Live preview** renders the unsaved markdown (debounced, side by side on wide
  screens) through the same `MarkdownRenderer` the client's page uses, so it
  can't drift from the real thing.

Both are progressive enhancement: with JavaScript off the textarea still works,
the chips just do nothing and no preview appears.

## Importing prototype content

```sh
bin/rails 'dossier:import[nuxt-prototype/content/d/ji4n-managing-agent/index.md,account-slug]'
```

The account may be left off while there is only one on the box.

Imports as an **unpublished** dossier — review it in `/admin`, then publish.
Unpublished dossiers 404 publicly. The prototype's MDC directives
(`::callout{…}` … `::`) are rewritten to the fenced YAML blocks above on the
way in.

## Deploy

Kamal to a VPS (`config/deploy.yml`); the SQLite files live on a persistent
volume under `storage/`. Back up with `sqlite3 .backup`; Litestream is a
documented upgrade, not a dependency.
