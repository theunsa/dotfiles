# Dossier

Self-hosted client spaces: proposals, roadmaps and phase progress as a single
shareable link (`/d/<client-slug>`), sent via WhatsApp, opened on a phone.

Markdown in, polished page out. Nuxt 4 + @nuxt/content v3 + @nuxt/ui v4, static.

## Start here

- **`docs/PLAN.md`** — the implementation plan. Build exactly v1 scope, nothing more.
- **`docs/first-client-proposal-draft.md`** — content for the first client page
  (ported into `content/d/ji4n-managing-agent/index.md`; prices are placeholders).

## Run it

```bash
pnpm install
pnpm dev          # http://localhost:3000
pnpm generate     # static output in .output/public
```

## Add a client

One folder, one file:

```bash
mkdir -p content/d/$(node -e "process.stdout.write(Math.random().toString(36).slice(2,6))")-acme
$EDITOR content/d/<that-slug>/index.md
```

Front matter:

```yaml
---
title: Getting your ticket chaos under control   # the page headline
description: One line, used for the link preview
client: Acme Body Corporate                       # shown as "Prepared for ..."
date: 12 September 2026
whatsapp: "+27821234567"                          # E.164, powers the CTA
whatsappText: "Hi, I read the proposal — let's talk about Step 1"  # optional
whatsappLabel: WhatsApp me                        # optional
---
```

The random 4-character prefix is the whole security model — see below.

## Writing content

Body is ordinary markdown starting at `##` (the `#` headline comes from
`title`). Three components are available, and only these three:

**`::steps`** — the phase cards with a price line.

```md
::steps
---
items:
  - title: Discovery
    price: R 18 000 fixed
    body: 2–3 weeks. You get a working demo of your ticket flow.
    note: This is all you commit to today.
  - title: Go live
    price: R 60 000–90 000 fixed
    body: Helpdesk live with all 12 mailboxes.
---
::
```

**`::callout`** — the reassurance line.

```md
::callout{title="You only commit to Step 1"}
Every step is priced before it starts, and each one stands on its own.
::
```

Optional: `icon="i-lucide-shield-check"`, `color="primary"`.

**`::faq`** — collapsible questions.

```md
::faq
---
items:
  - label: Does this replace WeConnectU?
    content: No. WeConnectU stays exactly as it is.
---
::
```

## Security model

Unguessable slug only — a Google-Docs-style share link. There is no auth.

- Client pages send `noindex, nofollow, noarchive, noimageindex`.
- `public/robots.txt` disallows `/d/`.
- Nothing links to a client page from anywhere on the site.

**Rule: nothing POPIA-sensitive goes in `content/d/`.** A passcode gate is a v2
item; until it exists, treat every dossier as "anyone with the link can read it".

## Deploy

```bash
cp .env.example .env      # set NUXT_PUBLIC_SITE_URL, DEPLOY_HOST, DEPLOY_PATH
pnpm deploy               # generate + rsync
```

`pnpm generate` writes a plain static site to `.output/public` — serve it with
anything. HTTPS is required: WhatsApp only renders a link preview over TLS, and
the client is judging you by the padlock.

Caddy is one line:

```caddyfile
dossier.example.com {
	root * /var/www/dossier
	file_server
	try_files {path} {path}/ {path}.html /404.html
}
```

Nginx equivalent: `try_files $uri $uri/ $uri.html =404;` with
`error_page 404 /404.html;`.

### Client pages and prerendering

Client pages are linked from nowhere, so the prerender crawler cannot discover
them. `nuxt.config.ts` reads `content/d/*` at build time and adds each folder as
an explicit prerender route. Add a folder, rebuild, done — no config edit.

## Decisions taken during the build

The plan's budget was one focused day, with "choose the simpler option and note
it in the README" as the tie-breaker. These are the calls made under that rule:

- **Accent colour**: `primary: orange` on a `stone` neutral — warm and
  professional, and one line in `app/app.config.ts` to change. Brand name,
  tagline and contact email live in that same file.
- **MDC tag mapping**: Nuxt UI v4 ships its own `ProseCallout` and `ProseSteps`,
  which hijack `::callout` and `::steps`. Rather than fight component priority,
  `nuxt.config.ts` maps the three authoring tags explicitly at
  `DossierSteps` / `DossierCallout` / `DossierFaq`. The markdown API is
  unchanged; the mapping is the thing to look at if a tag ever renders wrong.
- **CTA placement**: both. End-of-page CTA card on every screen size, plus a
  sticky bottom bar below `sm` — on a phone the button should never be more
  than a thumb away.
- **Typography**: Nuxt UI's Prose components, not `@tailwindcss/typography`.
  One less dependency; `.dossier-prose` in `app/assets/css/main.css` only bumps
  the reading size for phones.
- **Root page**: a plain Vue page, not a content file. It is three lines of
  text and never changes per client.

## Still placeholder — fill in before sending anything

- `content/d/ji4n-managing-agent/index.md`: `client`, `date`, the `whatsapp`
  number (currently `+27000000000`, so the CTA goes nowhere), and the prices
  `R [X]` / `R [Y]–[Z]`.
- The FAQ entries on that page were written from claims in the proposal draft,
  which had no FAQ of its own. Read them before the client does.
- Rename the folder if `ji4n-managing-agent` should carry the real client name —
  keep a random prefix.
- `app/app.config.ts`: tagline and contact email.
