# Dossier — Implementation Plan

**Dossier**: a self-hosted web tool for presenting proposals, roadmaps and phase progress to clients as a
single shareable link (opened mostly on a phone, via WhatsApp). Internal tool + brand builder;
not a product for sale.

This plan is written to be handed to an AI agent for implementation. Keep v1 ruthlessly small.

## Why Nuxt Content (not Rails / Writebook)

- Writebook is for *books* — linear chapters, one public site. Wrong shape for per-client
  proposal/status spaces, and forking it means owning a Rails app for a layout problem.
- Rails would work but brings a server, a database, and auth machinery that v1 doesn't need.
  V1 has no user input at all — it's rendered markdown.
- Author already works in Nuxt daily (Nuxt UI, Nuxt Content skills in place). Content is
  markdown files in git — the Writebook *spirit* (write text, get a beautiful page) with zero
  runtime state. Static output deployable anywhere for ~free.
- If interactive features grow later (client comments, sign-off buttons), Nuxt server routes
  can be added incrementally — no rewrite.

## Stack

- **Nuxt 4** + **@nuxt/content v3** + **@nuxt/ui v4**
- Static generation (`nuxt generate`) — no database, no backend in v1
- Deploy: any static host / VPS with Caddy or Nginx (author will host on own domain)
- Repo: new standalone repo, name: `dossier`

## Core concept

One markdown file = one client-facing page. Clients live under unguessable slugs:

```
content/
  d/
    <client-slug>/            # e.g. mk7x-parkview  (random prefix = unguessable)
      index.md                # the client's landing page (v1: the proposal itself)
      proposal.md             # optional split later
      status.md               # later: phase progress
```

- URL: `https://<domain>/d/<client-slug>` — sent via WhatsApp ("d" for dossier).
- **Security model v1:** unguessable slug only (like a Google Docs share link). No auth.
  Rule: nothing POPIA-sensitive in content. `robots.txt` disallows `/d/`; add
  `noindex` meta on all client pages. Passcode gate is a v2 item.
- Root `/` page: minimal personal/brand landing page (name, one line, contact). Nothing else.

## V1 scope (the only scope — build this, stop)

1. **Nuxt project setup** — Nuxt 4, @nuxt/content, @nuxt/ui, static preset.
2. **Content collection** for `d/**` (page type). Front matter schema:
   ```yaml
   title: string
   client: string          # display name
   date: string
   whatsapp: string        # E.164 number for the CTA button, e.g. "+27821234567"
   ```
3. **Client page layout** (`/d/[...slug]`) — mobile-first scrolling narrative:
   - Sticky-top brand bar (author name/logo, small).
   - Rendered markdown body with good typography (Nuxt UI Prose components / `@nuxt/content`
     prose styling). Generous spacing, max-width ~65ch, large tap targets.
   - Section styling: h2 as clear visual breaks; support for a highlighted "steps" section.
   - **WhatsApp CTA button** — fixed/bottom or end-of-page: links to
     `https://wa.me/<number>?text=<url-encoded prefill>`. Prefill text from front matter
     (default: "Hi, I read the proposal — let's talk about Step 1").
   - `noindex` meta.
4. **MDC components** (keep to exactly these three, used from markdown):
   - `::steps` / step cards — renders the phases (Discovery / Go live / Ongoing) as visually
     distinct cards with price line. Nuxt UI Card-based.
   - `::callout` — for the "you only commit to Step 1" reassurance line. Nuxt UI Alert-based.
   - `::faq` — collapsible Q&A items (Nuxt UI Accordion / Collapsible).
5. **First real content**: port `docs/20260829_proposal-draft.md` (in the odoo-learn repo)
   into `content/d/<slug>/index.md`, using the components above.
6. **Design**: clean, warm, professional. Light + dark via Nuxt UI defaults. One accent
   colour (author's brand). Must look excellent on a 390px-wide phone screen first;
   desktop is the afterthought. No animations beyond subtle defaults.
7. **Deploy**: `nuxt generate` output + deploy script/instructions for the author's host.
   HTTPS required (WhatsApp preview + trust).

Acceptance check: author can (a) add a new client by creating one folder + one markdown
file, (b) run one deploy command, (c) send `https://domain/d/slug` on WhatsApp, and it
opens fast, looks professional on a phone, and the WhatsApp button replies to the author.

## Explicitly NOT in v1

- Auth/passcodes, client logins
- Forms, comments, sign-off/acceptance buttons
- CMS/admin UI (markdown in git *is* the admin)
- Multi-author, analytics dashboards (add plausible/umami later if wanted)
- PDF export
- Phase-progress tracking UI

## Later (v2+, only when client #2 exists or need is proven)

- `status.md` per client + a simple phase-timeline component (living client space:
  phases tick off, documents accumulate — retainer visibility)
- Lightweight passcode gate per client space (needed before any sensitive docs land there)
- "Accept proposal" button (records acceptance — first server route)
- Reusable proposal template with front-matter-driven pricing blocks
- Basic page-view ping (know when the client opened it)

## Implementation notes for the agent

- Use the project's `nuxt`, `nuxt-content`, and `nuxt-ui` skills for current v3/v4 APIs
  (collections + `queryCollection`, Tailwind Variants theming).
- Content collection config lives in `content.config.ts` (Nuxt Content v3 style).
- Keep components small; prefer Nuxt UI primitives over custom CSS.
- Slug generation: any short random prefix is fine (e.g. 4 chars base36) + readable name.
- Total v1 effort target: **one focused day**. If a decision threatens that budget,
  choose the simpler option and note it in the README.
